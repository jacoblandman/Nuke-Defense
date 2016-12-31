//
//  AppDelegate.swift
//  Nuke Destroyer
//
//  Created by Jacob Landman on 12/19/16.
//  Copyright © 2016 Jacob Landman. All rights reserved.
//

import UIKit
import CoreSpotlight
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    // this enum is for the quick actions
    
    enum ShortcutIdentifier: String {
        case DeveloperInfo
        case QuickPlay
        
        // use a custom initialiser that takes the full string, strips the prefix and then tries to initialise using the raw value
        init?(fullIdentifier: String) {
            guard let shortIdentifier = fullIdentifier.components(separatedBy: ".").last else { return nil }
            self.init(rawValue: shortIdentifier)
        }
        
        var type: String {
            return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
        }
    }
    
    var window: UIWindow?
    
    /// Saved shortcut item used as a result of an app launch, used later when app is activated.
    var launchedShortcutItem: UIApplicationShortcutItem?



    // ------------------------------------------------------------------------------------------
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        var shouldPerformAdditionalDelegateHandling = true
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            
            launchedShortcutItem = shortcutItem
            
            // This will block "performActionForShortcutItem:completionHandler" from being called.
            // this happens if a quick action was selected to open the app (not when it is in background)
            // mainly this is here to prevent any code after this within this method, so this isn't really necessary
            shouldPerformAdditionalDelegateHandling = false
        }
        
        return shouldPerformAdditionalDelegateHandling
    }
    
    // ------------------------------------------------------------------------------------------

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    // ------------------------------------------------------------------------------------------
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    // ------------------------------------------------------------------------------------------

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    // ------------------------------------------------------------------------------------------

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        guard let shortcut = launchedShortcutItem else { return }
        
        _ = handleShortcut(shortcutItem: shortcut)
        
        launchedShortcutItem = nil
    }
    
    // ------------------------------------------------------------------------------------------

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // ------------------------------------------------------------------------------------------
    
    open var landscapeOnly = true
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if landscapeOnly {
            return .landscape
        } else {
            return .allButUpsideDown    
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
//        
//        // If the user activity has the type CSSearchableItemActionType it means we're being launched as a result of a Spotlight search
//        if userActivity.activityType == CSSearchableItemActionType {
//            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
//                if var navigationController = window?.rootViewController as? UINavigationController {
//                    // pop to the root view controller bc if you are in one of the other table views when attempting to perform the "resume" or "iOS" quick action
//                    // then the quick action won't work because the topViewController won't be the InitialViewController
//                    navigationController.popToRootViewController(animated: false)
//                    // if the top view controller is not the game view controller then we need to pop again
//                    if let ViewController = navigationController.topViewController as? GameViewController {
//                        // now segue to the initial view
//                        ViewController.developerButtonTapped()
//                        if let nextViewController = navigationController.topViewController as? InitialViewController {
//                            nextViewController.performSegue(withIdentifier: "segueToIOSNoAnimation", sender: self)
//                            print(navigationController.topViewController)
//                            
//                            if let finalViewController = navigationController.topViewController as? ViewController {
//                                // now call the showTutorial function
//                                print(uniqueIdentifier)
//                                finalViewController.showTutorial(Int(uniqueIdentifier)!)
//                            }
//                        }
//                    } else {
//                        navigationController = window?.rootViewController as! UINavigationController
//                        navigationController.popToRootViewController(animated: false)
//                        if let ViewController = navigationController.topViewController as? GameViewController {
//                            // now segue to the initial view
//                            ViewController.developerButtonTapped()
//                            if let nextViewController = navigationController.topViewController as? InitialViewController {
//                                nextViewController.performSegue(withIdentifier: "segueToIOSNoAnimation", sender: self)
//                                if let finalViewController = navigationController.topViewController as? ViewController {
//                                    // now call the showTutorial function
//                                    finalViewController.showTutorial(Int(uniqueIdentifier)!)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        
//        return true
//    }
    
    // ------------------------------------------------------------------------------------------
    // function added for handling the quick actions
    // calls handle shortcut
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem: shortcutItem))
    }
    
    // ------------------------------------------------------------------------------------------
    // depending on the quick action selected, one of the button methods will be called
    
    private func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        let shortcutType = shortcutItem.type
        guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: shortcutType) else { return false }

        if let nc = window?.rootViewController as? UINavigationController {
            nc.popToRootViewController(animated: true)
            if let vc = nc.topViewController as? GameViewController {
                
                switch (shortcutIdentifier) {
                case .QuickPlay:
                    if !(vc.sceneLoaded) {
                        vc.loadScene()
                    }
                    vc.currentGame.beginPlay()
                    handled = true
                    break
                    
                case .DeveloperInfo:
                    vc.developerButtonTapped()
                    handled = true
                    break
                }
            }
        }
        
        return handled
    }
    
    // ------------------------------------------------------------------------------------------
}

