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
	case Hiker,	WinterSports = "Winter Sports",	Baseball,Basketball, Golf, Tennis, Soccer, Football, Boxing, MMA, Swimming, TableTennis = "Table Tennis", Gymnastics, Dancer, Rugby, Bowling, Frisbee, Cricket, SpeedBiking = "Speed Biking", MountainBiking = "Mountain Biking", Coach, WaterSkiing = "Water Skiing", Running, PowerLifting = "Power Lifting", BodyBuilding = "Body Building", Wrestling, StrongMan = "Strong Man", NASCAR, RallyRacing = "Rally Racing", Parkour, Model, Makeup, Actor, RunwayModel = "Runway Model", Designer, Brand, Stylist, HairStylist = "Hair Stylist", FashionArtist = "Fashion Artist", Painter, Sketcher, Musician, Band, SingerSongWriter = "Singer-Songwriter", SportsPhotography = "Sports Photography", RealEstatePhotography = "Real Estate Photography", CarPhotography = "Car Photography", AutomotivePhotography = "Automotive Photography", FashionPhotography = "Fashion Photography", NaturePhotography = "Nature Photography", UrbanPhotography = "Urban Photography", WildlifePhotography = "Wildlife Photography", LifestylePhotography = "Lifestyle Photography", GeneralPhotography = "General Photography", Driver, CarEnthusiast = "Car Enthusiast", Mechanic, Customizations, Modifications, Autobody, Tuning, CarBrand = "Car Brand", Artist, Athlete, Author, Blogger, Chef, Comedian, Entrepreneur, FashionModel = "Fashion Model", FilmDirector = "Film Director", FitnessModel = "Fitness Model", Gamer, GamingVideoCreator = "Gaming Video Creator", GovernmentOfficial = "Government Official", Journalist, MotivationalSpeaker = "Motivational Speaker", MovieCharacter = "Movie Character", MusicianBand = "Musician Band", NewsPersonality = "News Personality", Photographer, PoliticalCandidite = "Political Candidite", Politician, Producer, PublicFigure = "Public Figure", Scientist, VideoCreator = "Video Creator", Writer, Foodie, FoodCritic = "Food Critic", MartialArts = "Martial Arts", Other
}

enum categoryClass: String, CaseIterable {
	case popAccounts = "Popular Accounts"
	case Athletic = "Athletic"
	case Fashion = "Fashion"
	case Photography = "Photography"
	case Music = "Music"
	case Automotive = "Automotive"
}

let selectedBoxColor = UIColor(red: 255/255, green: 121/255, blue: 8/255, alpha: 1)

let allCategoryClasses: [categoryClass] = [.popAccounts, .Athletic, .Fashion, .Photography, .Music, .Automotive]

let ClassToCategories: [categoryClass: [Category]] = [.Athletic: Athletic, .Fashion: Fashion, .Photography: Photography, .Music: Music, .Automotive: Automotive, .popAccounts: PopAccounts]

//Categories that house subCategories.
let PopAccounts: [Category] = [.Actor, .Artist, .Athlete, .Author, .Band, .Blogger, .Chef, .Coach, .Comedian, .Dancer, .Entrepreneur, .FashionModel, .FilmDirector, .FitnessModel, .Gamer, .GamingVideoCreator, .GovernmentOfficial, .Journalist, .MotivationalSpeaker, .MovieCharacter, .Musician, .MusicianBand, .NewsPersonality, .Photographer, .PoliticalCandidite, .Politician, .Producer, .PublicFigure, .Scientist, .VideoCreator, .Writer, .Foodie, .FoodCritic]
let Athletic: [Category] = [.Hiker, .WinterSports, .Baseball, .Basketball, .Golf, .Tennis, .Soccer, .Football, .Boxing, .MartialArts, .MMA, .Swimming, .TableTennis, .Gymnastics, .Dancer, .Rugby, .Bowling, .Frisbee, .Cricket, .SpeedBiking, .MountainBiking, .WaterSkiing, .Running, .PowerLifting, .BodyBuilding, .Wrestling, .StrongMan, .NASCAR, .RallyRacing, .Parkour, .Dancer, .Coach]
let Fashion: [Category] = [.Model, .Makeup, .Actor, .RunwayModel, .Designer, .Brand, .Stylist, .HairStylist, .FashionArtist, .Painter, .Sketcher]
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
