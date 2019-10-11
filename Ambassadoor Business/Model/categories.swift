//
//  categories.swift
//  Ambassadoor Business
//
//  Created by Chris Chomicki on 4/12/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import UIKit

//COMPLETE FOR LATER
//account type enumeration
public enum Category: String, CaseIterable {
    case Hiker,
    WinterSports = "Winter Sports",
    Baseball,Basketball, Golf, Tennis, Soccer, Football, Boxing, MMA, Swimming, TableTennis = "Table Tennis", Gymnastics, Dancer, Rugby, Bowling, Frisbee, Cricket, SpeedBiking = "Speed Biking", MountainBiking = "Mountain Biking", Coach, WaterSkiing = "Water Skiing", Running, PowerLifting = "Power Lifting", BodyBuilding = "BodyBuilding", Wrestling, StrongMan = "Strong Man", NASCAR, RalleyRacing = "RalleyRacing", Parkour, Model, Makeup, Actor, RunwayModel = "Runway Model", Designer, Brand, Stylist, HairStylist = "Hair Stylist", FasionArtist = "Fasion Artist", Painter, Sketcher, Musician, Band, SingerSongWriter = "Singer-Songwriter", SportsPhotography = "Sports Photography", RealEstatePhotography = "Real Estate Photography", CarPhotography = "Car Photography", AutomotivePhotography = "Automotive Photography", FashionPhotography = "Fashion Photography", NaturePhotography = "Nature Photography", UrbanPhotography = "Urban Photography", WildlifePhotography = "Wildlife Photography", LifestylePhotography = "Liftstyle Photography", GeneralPhotography = "General Photography", Driver, CarEnthusiast = "Car Enthusiast", Mechanic, Customizations, Modifications, Autobody, Tuning, CarBrand = "Car Brand", Artist, Athlete, Author, Blogger, Chef, Commedian, Entrepreneuner, FasionModel = "Fasion Model", FilmDirector = "Film Director", FitnessModel = "Fitness Model", Gamer, GamingVideoCreator = "Gaming Video Creator", GovernmentOfficial = "Government Official", Journalist, ModivationalSpeaker = "Modivational Speaker", MovieCharacter = "Movie Character", MusicianBand = "Musician Band", NewsPersonality = "News Personality", Photographer, PoliticalCandidite = "Political Candidite", Politition, Producer, PublicFigure = "Public Figure", Scientist, VideoCreator = "Video Creator", Writer, Foodie, FoodCritic = "Food Critic", Other
}

enum categoryClass: String, CaseIterable {
    case popAccounts = "Popular Accounts"
    case Athletic = "Athletic"
    case Fashion = "Fashion"
    case Photography = "Photography"
    case Music = "Music"
    case Automotive = "Automotive"
    case Other = "Other"
}

let AmbassadoorColor = UIColor(red: 255/255, green: 121/255, blue: 8/255, alpha: 1)

let allCategoryClasses: [categoryClass] = [.popAccounts, .Athletic, .Fashion, .Photography, .Music, .Automotive, .Other]

let ClassToCategories: [categoryClass: [Category]] = [.Athletic: Athletic, .Fashion: Fashion, .Photography: Photography, .Music: Music, .Automotive: Automotive, .popAccounts: PopAccounts, .Other: Other]


//Categories that house subCategories.
let Other: [Category] = [.Other]
let PopAccounts: [Category] = [.Actor, .Artist, .Athlete, .Author, .Band, .Blogger, .Chef, .Coach, .Commedian, .Dancer, .Entrepreneuner, .FasionModel, .FilmDirector, .FitnessModel, .Gamer, .GamingVideoCreator, .GovernmentOfficial, .Journalist, .ModivationalSpeaker, .MovieCharacter, .Musician, .MusicianBand, .NewsPersonality, .Photographer, .PoliticalCandidite, .Politition, .Producer, .PublicFigure, .Scientist, .VideoCreator, .Writer, .Foodie, .FoodCritic]
let Athletic: [Category] = [.Hiker, .WinterSports, .Baseball, .Basketball, .Golf, .Tennis, .Soccer, .Football, .Boxing, .MMA, .Swimming, .TableTennis, .Gymnastics, .Dancer, .Rugby, .Bowling, .Frisbee, .Cricket, .SpeedBiking, .MountainBiking, .WaterSkiing, .Running, .PowerLifting, .BodyBuilding, .Wrestling, .StrongMan, .NASCAR, .RalleyRacing, .Parkour, .Dancer, .Coach]
let Fashion: [Category] = [.Model, .Makeup, .Actor, .RunwayModel, .Designer, .Brand, .Stylist, .HairStylist, .FasionArtist, .Painter, .Sketcher]
let Music: [Category] = [.Musician, .Band, .SingerSongWriter]
let Photography: [Category] = [.SportsPhotography, .RealEstatePhotography, .CarPhotography, .AutomotivePhotography, .FashionPhotography, .NaturePhotography, .UrbanPhotography, .WildlifePhotography, .LifestylePhotography, .GeneralPhotography]
let Automotive: [Category] = [.Driver, .CarEnthusiast, .Mechanic, .Customizations, .Modifications, .Autobody, .Tuning, .CarBrand]

var categoryListArray: [Section]! {
    didSet{
        //categoryList.removeAll()
        for value in allCategoryClasses {
            categoryListArray.append(Section.init(categoryTitle: value, categoryData: ClassToCategories[value]!, expanded: false))
        }
    }
}
