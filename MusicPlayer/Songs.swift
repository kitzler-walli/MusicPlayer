//
//  Songs.swift
//  MusicPlayer
//
//  Created by Geemakun Storey on 2016-12-29.
//  Copyright © 2016 geemakunstorey@storeyofgee.com. All rights reserved.
//

import Foundation

let path = Bundle.main.path(forResource: "-home-singing-public_html-singing-bell.com-wp-content-uploads-2014-10-Joy-to-the-world-re-mixed-Singing-Bell", ofType: "mp3")
let path2 = Bundle.main.path(forResource: "SilentNight", ofType: "mp3")
let path3 = Bundle.main.path(forResource: "GodSaveTheQueen", ofType: "mp3")
let joyToTheWorld = URL(fileURLWithPath: path!)
let silentNight = URL(fileURLWithPath: path2!)
let GodSaveTheQueen = URL(fileURLWithPath: path3!)

struct Song {
    let title: String
    let file: URL
}

let songs = [
    Song(title: "Joy To The World", file: joyToTheWorld),
    Song(title: "Silent Night", file: silentNight),
    Song(title: "God Save The Queen", file: GodSaveTheQueen)
]

