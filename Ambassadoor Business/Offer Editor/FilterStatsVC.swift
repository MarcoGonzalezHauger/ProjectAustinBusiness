//
//  FilterStatsVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 15/04/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class FilterStatsVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var avgLikes: UITextField!
    
    @IBOutlet weak var engagement: UITextField!
    
    var influencerStatsDelegate: InfluencerStatsDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard(textField: avgLikes)
        self.addDoneButtonOnKeyboard(textField: engagement)
        // Do any additional setup after loading the view.
    }
    
    override func doneButtonAction() {
        self.avgLikes.resignFirstResponder()
        self.engagement.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    /// Add % at end of the text when enter engagement text filed. restrict more than 20%.
    /// - Parameters:
    ///   - textField: UITextField referrance
    ///   - range: rage of text
    ///   - string: entered text
    /// - Returns: true or false
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if textField == engagement {
            
            if string == "" {
                if textField.text?.last == "%"{
                   let text = String((textField.text?.dropLast())!)
                    if text.count == 1 {
                        textField.text = ""
                        setTextCursor()
                        return false
                    }else if text.count > 1{
                        let lastText = text.dropLast()
                        textField.text = lastText + "%"
                        setTextCursor()
                        return false
                    }
                    
                }
            }
            
            if textField.text?.last == "%" {
                let text = (textField.text?.dropLast())! + string
                if Int(String(text))! > 20 {
                   self.showAlertMessage(title: "Alert", message: "engagement Should be 20% or below 20%") {
                    self.setTextCursor()
                   }
                   return false

                }else{
                    textField.text = text + "%"
                    setTextCursor()
                    return false
                }
            }else{
                textField.text = string + "%"
                setTextCursor()
                return false
            }
        }
        return true
    }
    
    @IBAction func textFieldDidChange(textField: UITextField){
         
    }
    
    /// Set cursor position in engagement text.
    func setTextCursor(){
        if let selectedRange = engagement.selectedTextRange {

            // and only if the new position is valid
            if let newPosition = engagement.position(from: selectedRange.start, offset: -1) {

                // set the new position
                engagement.selectedTextRange = engagement.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        
    }
    
    /// Dismiss current viewcontroller
    /// - Parameter sender: UIButton referrance
    @IBAction func cancelAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /// Check if user entered valid average likes and engagement. send average likes and engagement to InfluencerStatsDelegate delegate method. Dismiss current viewcontroller.
    /// - Parameter sender: UIButton referrance
    @IBAction func UseFilterAction(sender: UIButton){
        if self.avgLikes.text?.count == 0{
            self.showAlertMessage(title: "Alert", message: "Average Likes should not empty") {
                
            }
            return
        }
        
        if self.engagement.text?.count == 0 {
            self.showAlertMessage(title: "Alert", message: "Engagement should not empty") {
                
            }
            return
        }
        
        if Double(String((engagement.text?.dropLast())!)) == nil{
            self.showAlertMessage(title: "Alert", message: "Something Wrong!") {
                
            }
            return
        }
        
        self.influencerStatsDelegate?.sendInfluencerStats(avglikes: Double(self.avgLikes.text!)!, engagement: Double(Double(String((engagement.text!.dropLast())))! / 100) )
        self.dismiss(animated: true, completion: nil)
        
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
