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
let path4 = Bundle.main.path(forResource: "o-holy-night", ofType: "mp3")
let path5 = Bundle.main.path(forResource: "we-wish-you-a-merry-christmas", ofType: "mp3")
let path6 = Bundle.main.path(forResource: "-home-singing-public_html-singing-bell.com-wp-content-uploads-2014-11-The-Huron-Carol", ofType: "mp3")
let joyToTheWorld = URL(fileURLWithPath: path!)
let silentNight = URL(fileURLWithPath: path2!)
let GodSaveTheQueen = URL(fileURLWithPath: path3!)
let oHolyNight = URL(fileURLWithPath: path4!)
let weWishYou = URL(fileURLWithPath: path5!)
let huronCarol = URL(fileURLWithPath: path6!)

struct Song {
    let title: String
    let file: URL
}

let songs = [
    Song(title: "Joy To The World", file: joyToTheWorld),
    Song(title: "Silent Night", file: silentNight),
    Song(title: "God Save The Queen", file: GodSaveTheQueen),
    Song(title: "O Holy Night", file: oHolyNight),
    Song(title: "We Wish You A Merry Christmas", file: weWishYou),
    Song(title: "The Huron Carol", file: huronCarol)
]

