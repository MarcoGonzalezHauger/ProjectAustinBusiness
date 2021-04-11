//
//  OfferFilterVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 30/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class OfferFilterVC: BaseVC, InterestPickerDelegate {
    func newInterests(interests: [String]) {
        self.selectedInterestArray = interests
    }
    
    
    var selectedInterestArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

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
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let view = segue.destination as? InterestPickerPopupVC {
            view.currentInterests = selectedInterestArray
            view.delegate = self
        }
       
    }
    

}
