//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Geemakun Storey on 2016-12-29.
//  Copyright © 2016 geemakunstorey@storeyofgee.com. All rights reserved.
//
// Special thanks to Apple for laying the groundwork for the basic functinality for AVFoundation
// https://developer.apple.com/library/content/samplecode/AVFoundationSimplePlayer-iOS/Listings/Swift_AVFoundationSimplePlayer_iOS_PlayerViewController_swift.html
//
import UIKit
import CoreMedia
import AVFoundation


// KVO context used to differentiate KVO callbacks for this class versus other
// classes in its class hierarchy.

private var playerViewControllerKVOContext = 0

class ViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var playerButtonOutlet: UIButton!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var songLength: UILabel!
    @IBOutlet weak var timeElaspedLabel: UILabel!
    
    
    // MARK: Properties
    let player = AVPlayer()
    var playerItems = [AVPlayerItem]()
    var currentTrack = 0
    
    var currentTime: Double {
        get {
            return CMTimeGetSeconds(player.currentTime())
        }
        set {
            let newTime = CMTimeMakeWithSeconds(newValue, 1)
            player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    
    var duration: Double {
        guard let currentItem = player.currentItem else {return 0.0}
        
        return CMTimeGetSeconds(currentItem.duration)
    }
    
    var rate: Float {
        get {
            return player.rate
        }
        set {
            player.rate = newValue
        }
    }
    // A token recieved from timeTokensObserver Block
    private var timeObserverToken: Any?
    
    /*
     A formatter for individual date components used to provide an appropriate
     value for startTime and Duration.
     */
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
         Update the UI when these player properties change.
         
         Use the context parameter to distinguish KVO for our particular observers
         and not those destined for a subclass that also happens to be observing
         these properties.
         */
        addObserver(self, forKeyPath: #keyPath(ViewController.player.currentItem.duration), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(ViewController.player.rate), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(ViewController.player.currentItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backGround = CAGradientLayer().newColor()
        backGround.frame = self.view.bounds
        self.view.layer.insertSublayer(backGround, at: 0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    func previousTrack() {
        if currentTrack <= 0 {
            currentTrack = (playerItems.count - 1) < 0 ? 0 : (playerItems.count - 1)
        } else {
            currentTrack -= 1
        }
        //print("Previous Current Index: \(currentTrack)")
        playTrack()
    }
    
    func nextTrack() {
        if currentTrack > 1 {
            currentTrack = 0
        } else {
            currentTrack += 1
        }
      //  print("Current Index: \(currentTrack)")
        playTrack()
    }
    
    func playTrack() {
        // Get songs from resource
        // Will change this in future updates
        let path = Bundle.main.path(forResource: "-home-singing-public_html-singing-bell.com-wp-content-uploads-2014-10-Joy-to-the-world-re-mixed-Singing-Bell", ofType: "mp3")
        let path2 = Bundle.main.path(forResource: "SilentNight", ofType: "mp3")
        let path3 = Bundle.main.path(forResource: "GodSaveTheQueen", ofType: "mp3")
        let fileURL = URL(fileURLWithPath: path!)
        let newFile = URL(fileURLWithPath: path2!)
        let new3File = URL(fileURLWithPath: path3!)
        
        // Array of songs
        playerItems = [AVPlayerItem(url: fileURL), AVPlayerItem(url: newFile), AVPlayerItem(url: new3File)]

        if playerItems.count > 0 {
            player.replaceCurrentItem(with: playerItems[currentTrack])
            
            // Add observer to notifiy when the current track has finieshed playing
            let song = playerItems[currentTrack]
            NotificationCenter.default.addObserver(self,selector:#selector(ViewController.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: song)
            // Play song
            player.play()
            // Update the timer
            updateTimeLeft()
        }
    }
    
    func playerDidFinishPlaying() {
       // print("Song over")
        // Advance to next track
        nextTrack()
    }
    
    func updateTimeLeft() {
    // Make sure we don't have a strong reference cycle by only capturing self as weak.
        let interval = CMTimeMake(1, 1)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [unowned self] time in
            let timeElapsed = Float(CMTimeGetSeconds(time))
            
          //  self.timeSlider.value = Float(timeElapsed)
            self.timeElaspedLabel.text = self.createTimeString(time: timeElapsed)
        //    self.songArtist.text = duration?.durationText
        }
    }
    
    // MARK: - KVO Observation
    // Update UI when player.currentItem changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure that this KVO callback was intended for this view controller
        guard context == &playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(ViewController.player.currentItem.duration) {
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            } else {
                newDuration = kCMTimeZero
            }
            let hasValidDuration = newDuration.isNumeric && newDuration.value != 0
            let newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0
           // let currentTime = hasValidDuration ? Float(CMTimeGetSeconds(player.currentTime())) : 0.0
            
            songLength.text = createTimeString(time: Float(newDurationSeconds))
            
        }
    }
    
    // MARK: IBActions
    @IBAction func playButton(_ sender: UIButton) {
        if player.rate != 1.0 {
            if currentTime == duration {
                currentTime = 0.0
            }
            playTrack()
            playerButtonOutlet.setTitle("Pause", for: .normal)
        } else {
            player.pause()
            playerButtonOutlet.setTitle("Play", for: .normal)
        }
    }
    @IBAction func skipButton(_ sender: UIButton) {
        nextTrack()
    }
    @IBAction func previousButton(_ sender: UIButton) {
        previousTrack()
    }
    // MARK: Convenience
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
}

