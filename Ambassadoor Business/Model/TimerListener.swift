//
//  TimerListener.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 07/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation


class TimerClass: NSObject {

    var accountBalanceTimer: Timer?
    
    func scheduleUpdateBalanceTimer(){
        accountBalanceTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateAccountBalance), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        guard self.accountBalanceTimer != nil else {
            fatalError("No timer active, start the timer before you stop it.")
        }
        self.accountBalanceTimer?.invalidate()
    }
    
    @objc func updateAccountBalance(){
        //createLocalNotification(notificationName: "reloadDeposit", userInfo: [:])
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: "updatebalance"), object: nil, userInfo: [:])
        if let userID = UserDefaults.standard.object(forKey: "userid") as? String{
            setDepositDetails(userID: userID)
        }
    }
}

var TimerListener: TimerClass = TimerClass()


