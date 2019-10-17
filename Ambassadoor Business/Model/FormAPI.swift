//
//  FormAPI.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 10/17/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

func InitializeFormAPI(completed: (() -> Void)?) {
	let ref = Database.database().reference().child("Admin").child("FormAPIKey")
	ref.observeSingleEvent(of: .value) { (Snapshot) in
		if let apikey: String = Snapshot.value as? String {
			FormAPIKey = apikey
			if let comp = completed {
				comp()
			}
		}
	}
}

var FormAPIKey: String?

var zipCodeDic: [String: String] = [:]

func GetTownName(zipCode: String, completed: @escaping (_ cityState: String?, _ zipCode: String) -> () ) {
	
	//FORM API Key, subject to change.
	
	if (zipCodeDic[zipCode] ?? "") != "" {
		completed(zipCodeDic[zipCode]!, zipCode)
	}
	
	if let APIKey: String = FormAPIKey {
		guard let url = URL(string: "https://form-api.com/api/geo/country/zip?key=\(APIKey)&country=US&zipcode=" + zipCode) else { completed(nil, zipCode)
			return }
		var cityState: String = ""
		URLSession.shared.dataTask(with: url){ (data, response, err) in
			if err == nil {
				// check if JSON data is downloaded yet
				guard let jsondata = data else { return }
				do {
					do {
						// Deserilize object from JSON
						if let zipCodeData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
							if let result = zipCodeData["result"] {
								let city = result["city"] as! String
								let state = result["state"] as! String
								let stateDict = ["Alabama": "AL","Alaska": "AK","Arizona": "AZ","Arkansas": "AR","California": "CA","Colorado": "CO","Connecticut": "CT","Delaware": "DE","Florida": "FL","Georgia": "GA","Hawaii": "HI","Idaho": "ID","Illinois": "IL","Indiana": "IN","Iowa": "IA","Kansas": "KS","Kentucky": "KY","Louisiana": "LA","Maine": "ME","Maryland": "MD","Massachusetts": "MA","Michigan": "MI","Minnesota": "MN","Mississippi": "MS","Missouri": "MO","Montana": "MT","Nebraska": "NE","Nevada": "NV","New Hampshire": "NH","New Jersey": "NJ","New Mexico": "NM","New York": "NY","North Carolina": "NC","North Dakota": "ND","Ohio": "OH","Oklahoma": "OK","Oregon": "OR","Pennsylvania": "PA","Rhode Island": "RI","South Carolina": "SC","South Dakota": "SD","Tennessee": "TN","Texas": "TX","Utah": "UT","Vermont": "VT","Virginia": "VA","Washington": "WA","West Virginia": "WV","Wisconsin": "WI","Wyoming": "WY"]
								cityState = city + ", " + (stateDict[state] ?? state)
							}
						}
						DispatchQueue.main.async {
							zipCodeDic[zipCode] = cityState
							completed(cityState, zipCode)
						}
					}
				} catch {
					print("JSON Downloading Error!")
				}
			}
		}.resume()
	} else {
		InitializeFormAPI {
			GetTownName(zipCode: zipCode, completed: completed)
		}
	}
}

func GetStates() -> [String] {
	let states = ["Alaska",
	"Alabama",
	"Arkansas",
	"American Samoa",
	"Arizona",
	"California",
	"Colorado",
	"Connecticut",
	"District of Columbia",
	"Delaware",
	"Florida",
	"Georgia",
	"Guam",
	"Hawaii",
	"Iowa",
	"Idaho",
	"Illinois",
	"Indiana",
	"Kansas",
	"Kentucky",
	"Louisiana",
	"Massachusetts",
	"Maryland",
	"Maine",
	"Michigan",
	"Minnesota",
	"Missouri",
	"Mississippi",
	"Montana",
	"North Carolina",
	"North Dakota",
	"Nebraska",
	"New Hampshire",
	"New Jersey",
	"New Mexico",
	"Nevada",
	"New York",
	"Ohio",
	"Oklahoma",
	"Oregon",
	"Pennsylvania",
	"Puerto Rico",
	"Rhode Island",
	"South Carolina",
	"South Dakota",
	"Tennessee",
	"Texas",
	"Utah",
	"Virginia",
	"Virgin Islands",
	"Vermont",
	"Washington",
	"Wisconsin",
	"West Virginia",
	"Wyoming"]
	return states
}

func GetCitiesInState(state: String, completed: @escaping (_ cities: [String], _ state: String) -> () ) {
	var stateCode = state
	if state.count != 2 {
		let stateDict = ["Alabama": "AL","Alaska": "AK","Arizona": "AZ","Arkansas": "AR","California": "CA","Colorado": "CO","Connecticut": "CT","Delaware": "DE","Florida": "FL","Georgia": "GA","Hawaii": "HI","Idaho": "ID","Illinois": "IL","Indiana": "IN","Iowa": "IA","Kansas": "KS","Kentucky": "KY","Louisiana": "LA","Maine": "ME","Maryland": "MD","Massachusetts": "MA","Michigan": "MI","Minnesota": "MN","Mississippi": "MS","Missouri": "MO","Montana": "MT","Nebraska": "NE","Nevada": "NV","New Hampshire": "NH","New Jersey": "NJ","New Mexico": "NM","New York": "NY","North Carolina": "NC","North Dakota": "ND","Ohio": "OH","Oklahoma": "OK","Oregon": "OR","Pennsylvania": "PA","Rhode Island": "RI","South Carolina": "SC","South Dakota": "SD","Tennessee": "TN","Texas": "TX","Utah": "UT","Vermont": "VT","Virginia": "VA","Washington": "WA","West Virginia": "WV","Wisconsin": "WI","Wyoming": "WY"]
		stateCode = stateDict[state] ?? "NY"
	}
	if let APIKey: String = FormAPIKey {
		guard let url = URL(string: "https://form-api.com/api/geo/country/state/cities?key=\(APIKey)&country=US&state=\(stateCode)") else { completed([], state)
			return
		}
		URLSession.shared.dataTask(with: url){ (data, response, err) in
			if err == nil {
				// check if JSON data is downloaded yet
				guard let jsondata = data else { return }
				do {
					do {
						var cities: [String] = []
						// Deserilize object from JSON
						if let zipCodeData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
							if let results = zipCodeData["cities"] as? [AnyObject] {
								for city in results {
									if let cityName = city["city"] as? String  {
										cities.append(cityName)
									}
								}
							}
						}
						DispatchQueue.main.async {
							completed(cities, state)
						}
					}
				} catch {
					print("JSON Downloading Error!")
				}
			}
		}
	}
}
