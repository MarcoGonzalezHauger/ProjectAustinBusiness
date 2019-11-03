//
//  categories.swift
//  Ambassadoor Business
//
//  Created by Chris Chomicki on 4/12/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import UIKit

public let AllCategories: [String] = [
	"Animal Photography", //Animals
	"Pets",
	"Pet Product Reviewer",
	"Foodie", //Food
	"Chef",
	"Baker",
	"Food Photography",
	"Health Foods",
	"Food Critic",
	"Restaurant",
	"Diet Reviewer",
	"Meme Account", //Commedy
	"Comedian",
	"Stand up Comedy",
	"Family", //Lifestlye
	"Mother",
	"Father",
	"Blogger",
	"Vlogger",
	"Party Enthusiast",
	"Student",
	"International Travels",
	"Lifestyle Photography",
	"Winter Sports", //Sports
	"Baseball",
	"Basketball",
	"Tennis",
	"Soccer",
	"Football",
	"Boxing",
	"Martial Arts",
	"MMA",
	"Swimming",
	"Table Tennis",
	"Wrestling",
	"Frisbee",
	"Rowing",
	"NASCAR",
	"Dancing", //Athletics
	"Coach",
	"Body Building",
	"Power Lifting",
	"Trick Shots",
	"Sports Compilations",
	"General Photography", //Photography
	"Wild Life Photography",
	"Nature Photography",
	"Urban Photography",
	"Lifestyle Photography",
	"Fashion Photography",
	"Food Photography",
	"Car Photography",
	"Car Enthusiast", //Automotive
	"Driver",
	"Mechanic",
	"Modifications",
	"Car Photography",
	"Do It Yourself", //Crafts
	"Arts & Crafts",
	"Construction",
	"Computer Building", //Technology
	"Engineer",
	"Software Developer",
	"Tech Reviewer",
	"Tech Tutorials",
	"Board Games", //Gaming
	"Computer Gaming",
	"Gaming Video Creator",
	"Professional Gamer",
	"Makeup Artist", //Fashion
	"Clothing Reviewer",
	"Model",
	"Stylist",
	"Designer",
	"Fashion Photography",
	"Singer/Songwriter", //Music
	"Band",
	"Musician",
	"Composer",
	"Producer",
	"Author", //Literature
	"Editor",
	"Publisher",
	"Journalist",
	"Actor", //Entertainment
	"Film Director",
	"Film Producer",
	"Motivational Speaker",
	"Magician",
	"Movie Account", //Movies & TV Shows
	"TV Show Account",
	"Fandom",
	"Movie & TV Show Reviews",
	"Democrat", //Political Account
	"Republican",
	"Independent",
	"Political Candidate",
	"Politician",
	"Real Estate Photography", //Real Estate
	"Real Estate Broker",
	"Landscaper",
	"Lawyer", //Professional
	"Nurse",
	"Mathematician",
	"Accountant",
	"Landscaper",
	"Construction",
	"Dental Professional",
	"Medical Professional",
	"Drawing/Painting", //Artist
	"Sculture",
	"Calligraphy",
	"Graphic Design",
	"Art Supply Reviewer",
	"Meme Page", //Meme Accounts
	"Adult Memes",
	"Teenage Memes",
	"Kid Memes",
	"Business", //Organization
	"Brand",
	"Entrepreneur",
	"Club",
	"College/University",
	"Festival",
	"Event"
]

enum categoryClass: String, CaseIterable {
	case petsAnimals = "Pets & Animals"
	case food = "Food"
	case comedy = "Comedy"
	case lifestyle = "Lifestyle & Travel"
	case sports = "Sports"
	case athletics = "Athletics"
	case photography = "Photography"
	case automotive = "Automotive"
	case crafts = "Crafts"
	case technology = "Technology"
	case gaming = "Gaming"
	case fashion = "Fashion"
	case music = "Music"
	case literature = "Literature"
	case entertainment = "Entertainment"
	case moviesandtv = "Movies & TV Shows"
	case political = "Political"
	case realestate = "Real Estate"
	case professional = "Professional"
	case artist = "Artist"
	case memes = "Memes"
	case organization = "Organization"
}

let selectedBoxColor = UIColor(red: 255/255, green: 121/255, blue: 8/255, alpha: 1)

let allCategoryClasses: [categoryClass] = [.petsAnimals, .food, .comedy, .lifestyle, .sports, .athletics, .photography, .automotive, .crafts, .technology, .gaming, .fashion, .music, .literature, .entertainment, .moviesandtv, .political, .realestate, .professional, .artist, .memes, .organization]

let ClassToCategories: [categoryClass: [String]] = [.petsAnimals: animals, .food: food, .comedy: comedy, .lifestyle: lifestyle, .sports: sports, .athletics: athletics, .photography: photography, .automotive: automotive, .crafts: crafts, .technology: technology, .gaming: gaming, .fashion: fashion, .music: music, .literature: literature, .entertainment: entertainment, .moviesandtv: moviesandshows, .political: political, .realestate: realestate, .professional: professional, .artist: aritst, .memes: meme, .organization: organization]

let animals = ["Animal Photography", //Animals
"Pets",
"Pet Product Reviewer"]
let food = ["Foodie", //Food
"Chef",
"Baker",
"Food Photography",
"Health Foods",
"Food Critic",
"Restaurant",
"Diet Reviewer"]
let comedy = ["Meme Account", //Commedy
"Comedian",
"Stand up Comedy"]
let lifestyle = ["Family", //Lifestlye
"Mother",
"Father",
"Blogger",
"Vlogger",
"Party Enthusiast",
"Student",
"International Travels",
"Lifestyle Photography"]
let sports = ["Winter Sports", //Sports
"Baseball",
"Basketball",
"Tennis",
"Soccer",
"Football",
"Boxing",
"Martial Arts",
"MMA",
"Swimming",
"Table Tennis",
"Wrestling",
"Frisbee",
"Rowing",
"NASCAR"]
let athletics = ["Dancing", //Athletics
"Coach",
"Body Building",
"Power Lifting",
"Trick Shots",
"Sports Compilations"]
let photography = ["General Photography", //Photography
"Wild Life Photography",
"Nature Photography",
"Urban Photography",
"Lifestyle Photography",
"Fashion Photography",
"Food Photography",
"Car Photography"]
let automotive = ["Car Enthusiast", //Automotive
"Driver",
"Mechanic",
"Modifications",
"Car Photography"]
let crafts = ["Do It Yourself", //Crafts
"Arts & Crafts",
"Construction"]
let technology = ["Computer Building", //Technology
"Engineer",
"Software Developer",
"Tech Reviewer",
"Tech Tutorials"]
let gaming = ["Board Games", //Gaming
"Computer Gaming",
"Gaming Video Creator",
"Professional Gamer"]
let fashion = ["Makeup Artist", //Fashion
"Clothing Reviewer",
"Model",
"Stylist",
"Designer",
"Fashion Photography"]
let music = ["Singer/Songwriter", //Music
"Band",
"Musician",
"Composer",
"Producer"]
let literature = ["Author", //Literature
"Editor",
"Publisher",
"Journalist"]
let entertainment = ["Actor", //Entertainment
"Film Director",
"Film Producer",
"Motivational Speaker",
"Magician"]
let moviesandshows = ["Movie Account", //Movies & TV Shows
"TV Show Account",
"Fandom",
"Movie & TV Show Reviews"]
let political = ["Democrat", //Political Account
"Republican",
"Independent",
"Political Candidate",
"Politician"]
let realestate  = ["Real Estate Photography", //Real Estate
"Real Estate Broker",
"Landscaper"]
let professional = ["Lawyer", //Professional
"Nurse",
"Mathematician",
"Accountant",
"Landscaper",
"Construction",
"Dental Professional",
"Medical Professional"]
let aritst = ["Drawing/Painting", //Artist
"Sculture",
"Calligraphy",
"Graphic Design",
"Art Supply Reviewer"]
let meme = ["Meme Page", //Meme Accounts
"Adult Memes",
"Teenage Memes",
"Kid Memes"]
let organization = ["Business", //Organization
"Brand",
"Entrepreneur",
"Club",
"College/University",
"Festival",
"Event"]


var categoryListArray: [Section]! {
    didSet{
        //categoryList.removeAll()
        for value in allCategoryClasses {
            categoryListArray.append(Section.init(categoryTitle: value, categoryData: ClassToCategories[value]!, expanded: false, selected: false))
        }
    }
}
