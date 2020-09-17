//
//  RegisterNewVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 17/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

//protocol RegisterCompanySegmentDelegate {
//    func registerStepSegmentIndex(index: Int)
//}
//
//protocol DismissDelegate {
//    func dismisRegisterPage()
//}

class RegisterNewVC: BaseVC,PageViewDelegate, DismissDelegate {
    
    @IBOutlet weak var stepSegment: UILabel!
    
    var registerCompanyPVCDelegate: RegisterCompanySegmentDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func pageViewIndexDidChangedelegate(index: Int) {
        self.stepSegment.text = "Step \(index + 1)/5"
    }
    
    func dismisRegisterPage(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PageView"{
            let view = segue.destination as! RegisterCompanyPVC
            view.pageViewDidChange = self
            view.parentReference = self
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
