//
//  ComapanyBasicVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 15/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ComapanyBasicVC: BaseVC,ImagePickerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var picLogo: UIButton!
    var urlString = ""
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var companyName: UITextField!
    var pageIdentifyIndexDelegate: PageIndexDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activity.isHidden = true
        self.picLogo.layer.cornerRadius = 75
        self.picLogo.layer.masksToBounds = true
        self.addDoneButtonOnKeyboard(textField: self.companyName)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoControlAction(sender: UIButton){
        self.performSegue(withIdentifier: "toGetPictureVC", sender: self)
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePicked(image: UIImage?, imageUrl: String?) {
        if image != nil {
            self.picLogo.setTitle("", for: .normal)
            self.picLogo.setBackgroundImage(image, for: .normal)
            self.activity.isHidden = false
            //        self.urlString = uploadImageToFIR(image: image!, path: (Auth.auth().currentUser?.uid)!)
            //w33OBske4KYNVNFk60NiKoSXw6v1
            //(Auth.auth().currentUser?.uid)!
            //"w33OBske4KYNVNFk60NiKoSXw6v1"
            uploadImageToFIR(image: image!,childName: "companylogo", path: (Auth.auth().currentUser?.uid)!) { (url, error) in
                self.activity.isHidden = true
                if error == false{
                    self.urlString = url
                    if self.companyName.text?.count != 0{
                    self.checkIfDetailGiven()
                    }
                    print("URL=",url)
                }else{
                    self.urlString = ""
                }
            }
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        self.checkIfDetailGiven()
        return true
    }
    
    @objc override func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scroll.contentInset = contentInset
    }
    
    @objc override func keyboardWasShown(notification : NSNotification) {
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scroll.contentInset = contentInset
        
    }
    
    func checkIfDetailGiven() {
        
        if urlString != ""{
            if companyName.text?.count != 0{
                global.registerCompanyDetails.imageUrl = urlString
                global.registerCompanyDetails.companyName = self.companyName.text!
                self.pageIdentifyIndexDelegate?.PageIndex(index: (self.view.tag + 1), viewController: self)
            }else{
                self.showAlertMessage(title: "Alert", message: "Please enter your company name") {}
            }
        }else{
            self.showAlertMessage(title: "Alert", message: "Please add your company logo") {}
        }
       
    }
    
    override func doneButtonAction(){
        
        self.companyName.resignFirstResponder()
        let scrollPoint = CGPoint(x: 0, y: 0)
        self.scroll .setContentOffset(scrollPoint, animated: true)
        
        self.checkIfDetailGiven()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? GetPictureVC {
        destination.delegate = self
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
