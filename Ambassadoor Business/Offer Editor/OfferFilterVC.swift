//
//  OfferFilterVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 30/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class OfferFilterVC: BaseVC, selectedCategoryDelegate {
    
    func selectedArray(array: [String]) {
        self.selectedCategoryArray.removeAll()
        self.selectedCategoryArray.append(contentsOf: array)
    }
    
    var selectedCategoryArray = [String]()

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
        self.performSegue(withIdentifier: "toNewCategoryTVC", sender: self)
    }

    @IBAction func pickGender(sender: UIButton){
        
        ShowGenderPicker(self) { (newGender) in
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "toNewCategoryTVC"{
        if let viewNav = segue.destination as? UINavigationController{
            if let view = viewNav.viewControllers.first as? CategoryTVC{
                view.selectedValues = selectedCategoryArray
                view.delegateCategory = self
            }
        }
            
        }
    }
    

}
