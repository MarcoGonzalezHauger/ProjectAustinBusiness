//
//  AppDelegate.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 2/14/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseCore
import FirebaseInstanceID
//import Braintree
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

	var window: UIWindow?
    
    override init() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = false
		InitializeZipCodeAPI(completed: nil)
    }

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = false
        InitializeZipCodeAPI(completed: nil)
        Stripe.setDefaultPublishableKey("pk_test_8Rwst6t9gr25jXYXC4NHmiZK001i78iYO7")
        //BTAppSwitch.setReturnURLScheme("com.develop.sns.paypal")
        getAdminValues { (error) in
           print("fd=",Singleton.sharedInstance.getAdminFS())
        }
        UNUserNotificationCenter.current().delegate = self
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            guard granted else {return}
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
                
            }
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(tokenRefreshNotification(_:)), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
		return true
	}
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let deviceTokenString1 = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("deviceToken1=",deviceTokenString1)
        
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                //print("avvv=",InstanceID.instanceID().token()!)
            }
        }
    }

    //Called if unable to register for APNS.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {


    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]){
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void){
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        completionHandler([.badge,.sound, .alert])
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
//        if url.scheme?.localizedCaseInsensitiveCompare("com.develop.sns.paypal") == .orderedSame {
//            return BTAppSwitch.handleOpen(url, options: options)
//        }
        return false
    }

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.versionUpdateValidation()
	}
    
//    func versionUpdateValidation(){
//        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
//
//        let ref = Database.database().reference().child("LatestAppVersion").child("Businessversion")
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//
//            let latestVersion = snapshot.value as! String
//            if (latestVersion == appVersion) {
//
//            }else{
//                let alertMessage = "A new version of Application is available, Please update to version " + latestVersion;
//
//                let topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
//                topWindow?.rootViewController = UIViewController()
//                topWindow?.windowLevel = UIWindow.Level.alert + 1
//                let alert = UIAlertController(title: "Update is avaliable", message: alertMessage, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "confirm"), style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
//                    // continue your work
//
//                    // important to hide the window after work completed.
//                    // this also keeps a reference to the window until the action is invoked.
//                    topWindow?.isHidden = true // if you want to hide the topwindow then use this
//                    //            topWindow? = nil // if you want to hide the topwindow then use this
//
//                    if let url = URL(string: "itms-apps://itunes.apple.com/app"),
//                        UIApplication.shared.canOpenURL(url){
//                        if #available(iOS 10.0, *) {
//                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                        } else {
//                            UIApplication.shared.openURL(url)
//                        }
//                    }
//
//
//                }))
//                topWindow?.makeKeyAndVisible()
//                topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
//
//            }
//        })
//    }
    
        func versionUpdateValidation(){

                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                
                let ref = Database.database().reference().child("LatestAppVersion").child("Businessversion")
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let latestVersion = snapshot.value as! String
                    let versionCompare = appVersion!.compare(latestVersion, options: .numeric)
                    if versionCompare == .orderedDescending || versionCompare == .orderedSame {
                        
                    }else{
                        let alertMessage = "A new version of Application is available, Please update to version " + latestVersion;

                        let topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
                        topWindow?.rootViewController = UIViewController()
                        topWindow?.windowLevel = UIWindow.Level.alert + 1
                        let alert = UIAlertController(title: "Update is avaliable", message: alertMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "confirm"), style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                            // continue your work
                            
                            // important to hide the window after work completed.
                            // this also keeps a reference to the window until the action is invoked.
                            topWindow?.isHidden = true // if you want to hide the topwindow then use this
                            //            topWindow? = nil // if you want to hide the topwindow then use this
                                                        
                            if let url = URL(string: "itms-apps://itunes.apple.com/app"),
                                UIApplication.shared.canOpenURL(url){
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(url)
                                }
                            }
                            
                            
                        }))
                        topWindow?.makeKeyAndVisible()
                        topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                })
            
            
        }

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		// Saves changes in the application's managed object context before the application terminates.
		self.saveContext()
	}
    
        @objc func tokenRefreshNotification(_ notification: Notification) {
            
    
            InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    print("Error fetching remote instange ID: \(error)")
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                }
            }
        }

	// MARK: - Core Data stack

	lazy var persistentContainer: NSPersistentContainer = {
	    /*
	     The persistent container for the application. This implementation
	     creates and returns a container, having loaded the store for the
	     application to it. This property is optional since there are legitimate
	     error conditions that could cause the creation of the store to fail.
	    */
	    let container = NSPersistentContainer(name: "Ambassadoor_Business")
	    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
	        if let error = error as NSError? {
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	             
	            /*
	             Typical reasons for an error here include:
	             * The parent directory does not exist, cannot be created, or disallows writing.
	             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
	             * The device is out of space.
	             * The store could not be migrated to the current model version.
	             Check the error message to determine what the actual problem was.
	             */
	            fatalError("Unresolved error \(error), \(error.userInfo)")
	        }
	    })
	    return container
	}()

	// MARK: - Core Data Saving support

	func saveContext () {
	    let context = persistentContainer.viewContext
	    if context.hasChanges {
	        do {
	            try context.save()
	        } catch {
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	            let nserror = error as NSError
	            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
	        }
	    }
	}

}

