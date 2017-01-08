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
    @IBOutlet weak var skipButtonOutlet: UIButton!
    @IBOutlet weak var previousButtonOutlet: UIButton!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var songLength: UILabel!
    @IBOutlet weak var timeElaspedLabel: UILabel!
    @IBOutlet weak var swipeGesture: UISwipeGestureRecognizer!
    
    
    // MARK: Properties
    let player = AVPlayer()
    var playerItems = [AVPlayerItem]()
    var currentTrack = 0
    
    let songsList = songs
    
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
        // Continue to loop through playlist when app is in background
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
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
        if currentTrack > 4 {
            currentTrack = 0
        } else {
            currentTrack += 1
        }
      //  print("Current Index: \(currentTrack)")
        playTrack()
    }
    
    func playTrack() {
        // Get file path from songsList array and pass into AVPlayerItem Array
        playerItems = [AVPlayerItem(url: songsList[0].file), AVPlayerItem(url: songsList[1].file), AVPlayerItem(url: songsList[2].file), AVPlayerItem(url: songsList[3].file), AVPlayerItem(url: songsList[4].file), AVPlayerItem(url: songsList[5].file)]

        if playerItems.count > 0 {
            player.replaceCurrentItem(with: playerItems[currentTrack])
            
            // Add observer to notifiy when the current track has finieshed playing
            let song = playerItems[currentTrack]
            NotificationCenter.default.addObserver(self,selector:#selector(ViewController.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: song)
            // Play song
            player.play()
            
            updateSongTitle()
            
            skipButtonOutlet.isEnabled = true
            previousButtonOutlet.isEnabled =  true
            // Update the timer
            updateTimeLeft()
        }
    }
    
    func playerDidFinishPlaying() {
        // Advance to next track
        nextTrack()
    }
    
    func updateSongTitle() {
        // Get current index of song to set title and change title
        let songIndex = currentTrack
        if currentTrack == songIndex {
            songTitle.text = songsList[songIndex].title
        }
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
        playerButtonOutlet.setTitle("Pause", for: .normal)
    }
    @IBAction func previousButton(_ sender: UIButton) {
        previousTrack()
        playerButtonOutlet.setTitle("Pause", for: .normal)
    }
    // MARK: Convenience
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
}

