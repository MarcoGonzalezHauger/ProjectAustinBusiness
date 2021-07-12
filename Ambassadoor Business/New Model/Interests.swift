//
//  Interests.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/29/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

var AllInterests: [String] = getInterests()

func getInterests() -> [String] {
    var keys: [String] = []
    for k: String in EmojiInterests.keys {
        keys.append(k)
    }
    return keys
}

var EmojiInterests: [String: String] = [
    "Vegan":"🌱", //Diet Preferences
    "Vegetarian":"🥕",
    "Pescaterian":"🐠",
    "Gluten Free":"🍞",
    "Lactose Intolerant":"🧀",
    "Paleo":"🥩",
    "Pets":"🐕",
    "Foodie":"🍽", //Food
    "Cook":"🧑‍🍳",
    "Meme Account":"🧢", //Comedy
    "Comedian":"🤣",
    "Lifestyle":"😎", //Lifestlye
    "Family":"🏡",
    "Adventurer":"🗺",
    "Blogger":"🖥",
    "Vlogger":"🤳🏻",
    "Student":"🎓",
    "Winter Sports":"⛷", //Sports & Athletics
    "Baseball":"⚾️",
    "Basketball":"🏀",
    "Golf":"🏌️‍♂️",
    "Tennis":"🎾",
    "Soccer":"⚽️",
    "Football":"🏈",
    "Boxing":"🥊",
    "Martial Arts":"🥋",
    "MMA":"☠️",
    "Swimming":"🏊",
    "Table Tennis":"🏓",
    "Wrestling":"🤼‍♀️",
    "Frisbee":"🥏",
    "Rowing":"🚣",
    "NASCAR":"🏁",
    "Dance":"💃🏻",
    "Coach":"📢",
    "Hockey":"🏒",
    "Archery":"🏹",
    "Body Building":"💪",
    "Power Lifting":"🏋️‍♀️",
    "Other Sports":"🏸",
    "Car Enthusiast":"🏎", //Automotive
    "Mechanic":"🔧",
    "Arts & Crafts":"🧵",
    "Construction":"🏗",
    "Computers":"💻", //Technology
    "Engineering":"⚙️",
    "Software Development":"🧑‍💻",
    "Tech Reviews":"🎥",
    "Board Games":"🎲", //Gaming
    "Computer Gaming":"🎮",
    "Fashion":"👗", //Fashion
    "Makeup":"💄",
    "Clothing":"👚",
    "Modeling":"👠",
    "Music":"🎼", //Music
    "Singer":"🎤",
    "Reading":"📚", //Literature
    "Writing":"🖋",
    "Acting":"🎭", //Entertainment
    "Motivational Speaking":"🌟",
    "Magic":"🪄",
    "Movies":"🍿", //Movies & TV Shows
    "TV Shows":"📺",
    "Politics":"🗳", //Politics
    "Democrat":"🐎",
    "Republican":"🐘",
    "Independent":"🇺🇸",
    "Architecture":"🏛", //Real Estate
    "Real Estate":"🏘",
    "Interior Decorating":"🖼",
    "Investing":"📈", //interests
    "Math":"🧮",
    "Science":"🔬",
    "Drawing/Painting":"🖌", //Artist
    "Artsy":"🎨",
    "Calligraphy":"✒️",
    "Photography":"📷",
    "Graphic Design":"📐",
    "Business":"💼", //Organization
    "Entrepreneurship":"💡",
    "Advertising":"📣"
]
