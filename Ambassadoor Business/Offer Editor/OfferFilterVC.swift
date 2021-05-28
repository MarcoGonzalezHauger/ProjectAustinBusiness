//
//  OfferFilterVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 30/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol InfluencerStatsDelegate {
    func sendInfluencerStats(avglikes: Double, engagement: Double)
}

protocol ZipcodeCollectionDelegate {
    func sendZipcodeCollection(zipcodes: [String])
}

class OfferFilterVC: BaseVC, InterestPickerDelegate, InfluencerStatsDelegate, ZipcodeCollectionDelegate {
    
    
    func sendZipcodeCollection(zipcodes: [String]) {
         selectedZipCodes = zipcodes
        DispatchQueue.main.async {
            self.filteredInfText.text = "\(self.filterInfluencers().count)"
        }
         
    }
    
    func sendInfluencerStats(avglikes: Double, engagement: Double) {
        self.averageLikes = avglikes
        self.engagement = engagement
        self.filteredInfText.text = "\(self.filterInfluencers().count)"
    }
    
    func newInterests(interests: [String]) {
        self.selectedInterestArray = interests
        self.filteredInfText.text = "\(self.filterInfluencers().count)"
    }
    
    
    var selectedInterestArray = [String]()
    var selectedZipCodes = [String]()
    var selectedGender = ""
    var averageLikes = 0.0
    var engagement = 0.0
    
    var draftOffer: DraftOffer!
    
    @IBOutlet weak var filteredInfText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.filteredInfText.text = "\(globalBasicInfluencers.count)"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelAction(sender: Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pickLocation(sender: UIButton){
        self.performSegue(withIdentifier: "toLocationFilter", sender: self)
    }
    
    @IBAction func pickInterest(sender: UIButton){
        self.performSegue(withIdentifier: "toInterestPicker", sender: self)
    }

    @IBAction func pickGender(sender: UIButton){
        
        ShowGenderPicker(self) { (newGender) in
            self.selectedGender =  newGender
            self.filteredInfText.text = "\(self.filterInfluencers().count)"
        }
        
    }
    
    @IBAction func pickStatAction(sender: UIButton){
        self.performSegue(withIdentifier: "toFilterStats", sender: self)
    }
    
    func getGenders(gender: String) -> [String] {
        
        switch gender {
        case "All":
            return ["Male", "Female", "Other"]
        default:
            return [gender]
        }
        
    }
    
    func filterInfluencers() -> [BasicInfluencer] {
        
        var filteredInfluencers = [BasicInfluencer]()
        
        
        for user in globalBasicInfluencers {
            var locationMatch = (self.selectedZipCodes.count == 0)
            var categoryMatch = (self.selectedInterestArray.count == 0)
            var genderMatch = (self.selectedGender == "" || self.selectedGender == "All")
            var likesMatch = (self.averageLikes == 0.0)
            var engagementMatch = (self.engagement == 0.0)
            
            if !locationMatch {
                if self.selectedZipCodes.contains(user.zipCode) {
                    locationMatch = true
                }
            }
            
            if !categoryMatch && locationMatch {
                
                    for category in user.interests {
                        if self.selectedInterestArray.contains(category){
                           categoryMatch = true
                            break
                        }
                    }
            }
            
            
            
            if !genderMatch && categoryMatch && locationMatch {
                genderMatch = self.selectedGender == user.gender
            }
            
            if !likesMatch && genderMatch && categoryMatch && locationMatch {
                likesMatch = user.averageLikes >= self.averageLikes
            }
            
            if !engagementMatch && likesMatch && genderMatch && categoryMatch && locationMatch {
                print("en=",user.engagementRate)
                engagementMatch = user.engagementRate >= self.engagement
            }
            
            if engagementMatch && likesMatch && locationMatch && categoryMatch && genderMatch {
                filteredInfluencers.append(user)
            }
        }
        
        return filteredInfluencers
        
    }
    
    @IBAction func sendOfferAction(sender: UIButton){
        
        var filterDict = [String: AnyObject]()
        
        if self.selectedZipCodes.count != 0{
            filterDict["acceptedZipCodes"] = self.selectedZipCodes as AnyObject
        }
        
        if self.selectedInterestArray.count != 0 {
            filterDict["acceptedInterests"] = self.selectedInterestArray as AnyObject
        }
        
        if self.selectedGender != "" {
            filterDict["acceptedGenders"] = getGenders(gender: self.selectedGender) as AnyObject
        }
        
        filterDict["mustBe21"] = true as AnyObject
        filterDict["minimumEngagementRate"] = self.engagement as AnyObject
        filterDict["averageLikes"] = self.averageLikes as AnyObject
        
        let filter = OfferFilter.init(dictionary: filterDict, businessId: MyCompany.businessId, basicId: draftOffer.basicId!)
        
        self.performSegue(withIdentifier: "toNewDistribute", sender: filter)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let view = segue.destination as? InterestPickerPopupVC {
            view.currentInterests = selectedInterestArray
            view.delegate = self
        }
        
        if let view = segue.destination as? FilterStatsVC{
            view.influencerStatsDelegate = self
        }
        
        if let viewNav = segue.destination as? StandardNC {
            if let view = viewNav.viewControllers.first as? LocationFilterVC{
               view.zipCollection = self
            }
            
        }
        
        if let view = segue.destination as? NewDistributeVC {
            view.draftOffer = self.draftOffer
            view.filter = (sender as! OfferFilter)
        }
       
    }
    

}
