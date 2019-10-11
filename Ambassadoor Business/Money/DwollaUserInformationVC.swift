//
//  DwollaUserInformationVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 05/09/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class DwollaUserInformationVC: BaseVC,UITextFieldDelegate {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    //@IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var stateText: UITextField!
    @IBOutlet weak var postalCodeText: UITextField!
    @IBOutlet weak var dateOfBirth: UITextField!
    @IBOutlet weak var ssnText: UITextField!
    
    @IBOutlet weak var scroll: UIScrollView!
    var dobPickerView:UIDatePicker = UIDatePicker()
    
    var dwollaTokens = [String: AnyObject]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInputField()
        // Do any additional setup after loading the view.
    }
    
    // MARK: -Text Field Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    @objc override func keyboardWasShown(notification : NSNotification) {
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scroll.contentInset = contentInset
        
    }
    
    @objc override func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scroll.contentInset = contentInset
    }
    
    // MARK: Components
    
    func setInputField() {
        let newDateComponents = NSDateComponents()
        newDateComponents.month = 1
        newDateComponents.day = 0
        newDateComponents.year = 0
        dobPickerView.minimumDate = Calendar.current.date(byAdding: .year, value: -30, to: Date())

        dobPickerView.maximumDate = NSCalendar.current.date(byAdding: newDateComponents as DateComponents, to: NSDate() as Date)
        
        dobPickerView.datePickerMode = UIDatePicker.Mode.date
        
        self.dateOfBirth.inputView = dobPickerView
        dobPickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
        self.addDoneButtonOnKeyboard(textField: dateOfBirth)
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        // NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"EN"];
        let locale = NSLocale.init(localeIdentifier: "en_US")
        print(locale)
        //"MM/dd/YYYY HH:mm:ss",yyyy/MMM/dd HH:mm:ss
        //dateFormatter.dateFormat = "dd/MM/YYYY"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //        dateFormatter.dateFormat = "mm/dd/yyyy HH:mm:ss"
        dateFormatter.locale = Locale.current
        dateOfBirth.text = dateFormatter.string(from: sender.date)
        
        
    }
    
    override func doneButtonAction() {
        
        dateOfBirth.resignFirstResponder()
        
    }
    
    @IBAction func dismissAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitAction(sender: UIButton){
        //print("ip==",Validation.sharedInstance.getIP())
        //192.168.43.62
        if self.firstName.text?.count != 0 {
            
            if self.lastName.text?.count != 0 {
                
               // if self.emailAddress.text?.count != 0 {
                    
                    if self.addressText.text?.count != 0 {
                        
                        if self.cityText.text?.count != 0 {
                            
                            if self.stateText.text?.count != 0 {
                                
                                if self.postalCodeText.text?.count != 0 {
                                    
                                    if self.dateOfBirth.text?.count != 0 {
                                        
                                        if self.ssnText.text?.count != 0 {
                                            
                                            let params = ["firstName":self.firstName.text!,"lastName":self.lastName.text!,"email":Singleton.sharedInstance.getCompanyUser().email!,"ipAddress":"192.168.43.62","type": "personal","address1": self.addressText.text!,"city":self.cityText.text!,"state":self.stateText.text!,"postalCode":self.postalCodeText.text!,"dateOfBirth":self.dateOfBirth.text!,"ssn":self.ssnText.text!] as [String:AnyObject]
                                            let fullName = self.firstName.text! + " " + self.lastName.text!
                                            print("data=",params)
                                            global.dwollaCustomerInformation.firstName = self.firstName.text!
                                            global.dwollaCustomerInformation.lastName = self.lastName.text!
                                            NetworkManager.sharedInstance.createCustomerDwolla(params: params, accessToken: dwollaTokens["dAccessToken"] as! String) { (status, error, data,response) in
                                                
//                                                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//
//                                                print("dataString=",dataString)
                                                
                                                //print("vao=",response.)
                                                
                                                if error == nil {
                                                
                                                if let header = response as? HTTPURLResponse {
                                                    
                if header.statusCode == 201 {
                    print("headerfeild=",header.allHeaderFields["Location"]!)
                    let cusParams = ["plaidToken":self.dwollaTokens["dpToken"] as! String,"name":fullName]
                    let customerURL = header.allHeaderFields["Location"]! as! String
                    global.dwollaCustomerInformation.customerURL = customerURL
                    global.dwollaCustomerInformation.isFSAdded = false
                    createDwollaCustomerToFIR(object: global.dwollaCustomerInformation)
                    NetworkManager.sharedInstance.createFundingSourceForCustomer(params: cusParams as [String : AnyObject], accessToken: self.dwollaTokens["dAccessToken"] as! String, customerURL: customerURL) { (cusStatus, cusError, cusData, cusResponse) in
                        
                        let dataString = NSString(data: cusData!, encoding: String.Encoding.utf8.rawValue)
                        
                        print("dataString=",dataString)
                        
                        if cusError == nil {
                            
                            if let cusHeader = cusResponse as? HTTPURLResponse {
                                
                                if cusHeader.statusCode == 201 {
                                    
                                    let customerFSURL = cusHeader.allHeaderFields["Location"]! as! String
                                    
                                    global.dwollaCustomerInformation.customerFSURL = customerFSURL
                                    global.dwollaCustomerInformation.isFSAdded = true
                                    createDwollaCustomerToFIR(object: global.dwollaCustomerInformation)
                                    
                                    DispatchQueue.main.async(execute: {
                                    self.dismiss(animated: true, completion: nil)
                                    })
                                    
                                    
                                }
                                
                            }
                            
                        }
                                                            
                    }
                        }
                                                    
                        }
                                                    
                        }
                                                

                                                
                        }
                                            
                                            
                        }else{
                                            
                                            self.showAlertMessage(title: "Alert", message: "Please enter your SSN") {
                                                
                                            }
                                            
                                        }
                                        
                                    }else{
                                        
                                        self.showAlertMessage(title: "Alert", message: "Please choose your Date Of Birth") {
                                            
                                        }
                                        
                                    }
                                    
                                }else{
                                    
                                    self.showAlertMessage(title: "Alert", message: "Please enter your PostalCode") {
                                        
                                    }
                                    
                                }
                                
                                
                            }else{
                                
                                self.showAlertMessage(title: "Alert", message: "Please enter State") {
                                    
                                }
                                
                            }
                            
                        }else{
                            
                            self.showAlertMessage(title: "Alert", message: "Please enter your city") {
                                
                            }
                            
                        }
                        
                    }else{
                        self.showAlertMessage(title: "Alert", message: "Please enter your Address") {
                            
                        }
                    }
                    
                //}
                //else{
                    
                //    self.showAlertMessage(title: "Alert", message: "Please enter your Email Address") {
                        
                //    }
               // }
                
                
            }else {
                self.showAlertMessage(title: "Alert", message: "Please enter your Last name") {
                    
                }
            }
            
        }else{
            self.showAlertMessage(title: "Alert", message: "Please enter your first name") {
                
            }
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
