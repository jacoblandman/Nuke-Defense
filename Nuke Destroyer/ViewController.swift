//
//  ViewController.swift
//  JTL
//
//  Created by Jacob Landman on 11/29/16.
//  Copyright © 2016 Jacob Landman. All rights reserved.
//

import UIKit
import SafariServices
import CoreSpotlight
import MobileCoreServices

class ViewController: UITableViewController, UIViewControllerPreviewingDelegate, SFSafariViewControllerDelegate {
    
    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    // projects is an array of projects, which are also arrays
    // each project will hold the project name and its subtitle
    var projects = [[String]]()
    var showAC: Bool = true
    var previewIndexPath: IndexPath?
    var safariViewController: SFSafariViewController?
    var alertController: UIAlertController?
    
    // METHODS
    // ------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fillProjectsArray()
        
        // load UserDefaults if it exists there already
        let defaults = UserDefaults.standard
        if let showAlertController = defaults.object(forKey: "showAC") as? Bool {
            showAC = showAlertController
        }
        
        if showAC {
            let ac = UIAlertController(title: "iOS Experience", message: "This view displays a list of the 39 projects completed during the 'Hacking With Swift' tutorial series. Various topics discussed within each project can be seen below the title. Selecting a cell will load a safari view where you can obtain more information about each project. Peek and pop if you dare. Also, upon visiting this table view, each project has been indexed so you can search in spotlight for topics such as 'CALayer', 'closures', etc.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Got It!", style: .default){ [unowned self] _ in
                self.alertController = nil
            })
            
            ac.addAction(UIAlertAction(title: "Don't show again", style: .default) { [unowned self] _ in
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: "showAC")
                self.alertController = nil
            })
            
            alertController = ac
            
            present(ac, animated: true)
        }
        
        title = "Hacking With Swift Tutorial Series"
        
        setupSearchableContent()
        
        // register our view controller for peek and pop, if 3D is available on the device
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    
    // ------------------------------------------------------------------------------------------
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let project = projects[indexPath.row]
        cell.textLabel?.attributedText = makeAttributedString(title: project[0], subtitle: project[1])
        
        return cell
    }
    
    // ------------------------------------------------------------------------------------------
    // the following two functions make sure auto layout does the hard work for us to automatically size every cell
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // nav height shoudl be 44
        let navHeight: CGFloat
        if let nc = navigationController {
            navHeight = nc.navigationBar.frame.size.height
        } else {
            print("the nav controller is nil")
            navHeight = 44
        }

        return (tableView.frame.size.height - navHeight) / 5.0
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // nav height shoudl be 44
        let navHeight: CGFloat
        if let nc = navigationController {
            navHeight = nc.navigationBar.frame.size.height
        } else {
            print("the nav controller is nil")
            navHeight = 44
        }

        return (tableView.frame.size.height - navHeight) / 5.0
    }
    
    // ------------------------------------------------------------------------------------------
    
    func fillProjectsArray() {
        projects.append(["Project 1: Storm Viewer", "Constants and variables, UITableView, UIImageView, FileManager, storyboards"])
        projects.append(["Project 2: Guess the Flag", "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+= and -=), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController"])
        projects.append(["Project 3: Social Media", "UIBarButtonItem, UIActivityViewController, the Social framework, URL"])
        projects.append(["Project 4: Easy Browser", "loadView(), WKWebView, delegation, classes and structs, URLRequest, UIToolbar, UIProgressView, key-value observing"])
        projects.append(["Project 5: Word Scramble", "Closures, method return values, booleans, NSRange"])
        projects.append(["Project 6: Auto Layout", "Get to grips with Auto Layout using practical examples and code"])
        projects.append(["Project 7: Whitehouse Petitions", "JSON, Data, UITabBarController"])
        projects.append(["Project 8: 7 Swifty Words", "addTarget(), enumerated(), count, index(of:), property observers, range operators"])
        projects.append(["Project 9: Grand Central Dispatch", "GCD, threading, DispatchQueue, async"])
        projects.append(["Project 10: Names to Faces", "UICollectionViewController, UIImagePickerController, UUID, CALayer, Data, UIAlertController"])
        projects.append(["Project 11: Pachinko", "SpriteKit, Node, PhysicsBody, Action, ContactDelegate, LabelNode, EmitterNode"])
        projects.append(["Project 12: UserDefaults", "NSCoding, NSKeyedUnarchiver, NSKeyedArchiver"])
        projects.append(["Project 13: Instafilter", "UISlider, Core Image, CIContext, CIFilter, UIImageWriteToSavedPhotosAlbum()"])
        projects.append(["Project 14: Whack-a-Penguin", "CropNode, Texture, Action, moveBy, asyncAfter()"])
        projects.append(["Project 15: Animation", "Animation, CGAffineTransform, switch/case"])
        projects.append(["Project 16: JavaScript Injection", "Safari extensions, NSExtensionItem, NotificationCenter"])
        projects.append(["Project 17: Swifty Ninja", "ShapeNode, AVAudioPlayer, Action Groups, BezierPath, CGPath, custom enums, sequences"])
        projects.append(["Project 18: Debugging", "using print(), using assert(), breakpoints, view debugging"])
        projects.append(["Project 19: Capital Cities", "MapKit, PinAnnotationView, Annotation, CLLocationCoordinate2D"])
        projects.append(["Project 20: Fireworks Night", "Timer", "follow()"])
        projects.append(["Project 21: Local Nofifications", "UserNotificationCenter, NotificationRequest, Acting on responses"])
        projects.append(["Project 22: Detect-a-Beacon", "Core Location, CLBeaconRegion, CLLocationManager, CLBeaconRegion"])
        projects.append(["Project 23: Space Race", "didBegin(), linearDamping, angularDamping, PhysicsContactDelegate, per-pixel collision"])
        projects.append(["Project 24: Swift Extensions", "Extensions, protocol-oriented programming"])
        projects.append(["Project 25: Selfie Share", "MCSession, MCBrowserViewController, MCPeerID"])
        projects.append(["Project 26: Marble Maze", "categoryBitMask, collisionBitMask, contactTestBitMask, CMMotionManager"])
        projects.append(["Project 27: Core Graphics", "UIGraphicsImageRenderer, Clipping paths, gradients, blend modes"])
        projects.append(["Project 28: Secret Swift", "iOS keychain, touch ID, LocalAuthentication"])
        projects.append(["Project 29: Exploding Monkeys", "Destructible terrain, Mixing UISlider and SKView, presentScene"])
        projects.append(["Project 30: Instruments", "Profiling, shadows, image caching, cell reuse"])
        projects.append(["Project 31: Multibrowser", "UIStackView, iPad multitasking, UIWebView"])
        projects.append(["Project 32: SwiftSearcher", "iOS Spotlight, SFSafariViewController, TableViewCell automatic sizing, dynamic type, attributed strings"])
        projects.append(["Project 33: What's that Whistle", "CloudKit, AVAudioRecorder, CKRecord, CKAsset, CloudKit dashboard, NSPredicate, CKQueryOperation, save(), CKReference, fetch, notifications with CloudKit"])
        projects.append(["Project 34: Four in a Row", "GameplayKit AI, GKGameModelPlayer, GKGameModel, GKGameModelUpdate, GKMinmaxStrategist"])
        projects.append(["Project 35: Random Numbers", "GameplayKit, GKRandomSource, GKShuffledDistribution, GKGaussianDistribution, GKRandomDistribution, arrayByShufflingObjects"])
        projects.append(["Project 36: Crashy Plane", "parallax scrolling, SKAudioNode, intro, game over"])
        projects.append(["Project 37: Psychic Tester", "CAEmitterLayer, CAGradientLayer, @IBDesignable, @IBInspectable, 3D card flip effect, 3D Touch, WCSession, watchOS app"])
        projects.append(["Project 38: GitHub Commits", "Core Data, NSFetchRequest, NSManagedObject, NSPredicate, NSSortDescriptor, NSFetchedResultsController"])
        projects.append(["Project 39: Unit testing with XCTest", "filter(), measure(), functions as parameters, user interface testing with XCTest"])
    }
    
    // ------------------------------------------------------------------------------------------
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        // NSFontAttributesName is the dictionary key that specifies what font the attributed text should be
        // should be provided with UIFont as its value
        // NSForegroundColorAttributeName is the dictionary key that specifies what text color to use.
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline), NSForegroundColorAttributeName: UIColor.purple]
        let subtitleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        // the title is created as mutable because we append the subtitle to the title to make one attributed string that can be returned
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: "\(subtitle)", attributes: subtitleAttributes)
        
        titleString.append(subtitleString)
        
        return titleString
    }
    
    // ------------------------------------------------------------------------------------------
    
    func showTutorial(_ which: Int) {
        if let url = URL(string: "https://www.hackingwithswift.com/read/\(which + 1)") {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            let navController = UINavigationController(rootViewController: vc)
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss as () -> Void))
            vc.navigationController?.isNavigationBarHidden = true
            vc.delegate = self
            safariViewController = vc
            self.navigationController!.present(navController, animated: true, completion: nil)
            //present(vc, animated: true)
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTutorial(indexPath.row)
    }
    
    // ------------------------------------------------------------------------------------------
    
    func index(item: Int) {
        let project = projects[item]
        
        // kUTTypeTexas as String tells iOS we want to store text in our indexed record
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = project[0]
        attributeSet.contentDescription = project[1]
        
        let item = CSSearchableItem(uniqueIdentifier: "\(item)", domainIdentifier: "com.hackingwithswift", attributeSet: attributeSet)
        // never expire index
        item.expirationDate = Date.distantFuture
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    // this function makes the projects searchable in the phone spotlight
    
    func setupSearchableContent() {
        for i in 0 ..< projects.count {
            index(item: i)
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        previewIndexPath = indexPath
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        if let url = URL(string: "https://www.hackingwithswift.com/read/\(indexPath.row + 1)") {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            let navController = UINavigationController(rootViewController: vc)
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss as () -> Void))
            vc.navigationController?.isNavigationBarHidden = true
            vc.delegate = self
            // is this the correct frame size?
            previewingContext.sourceRect = cell.frame
            safariViewController = vc
            return navController
        } else {
            return nil
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController!.present(viewControllerToCommit, animated: true, completion: nil)
    }
    
    // ------------------------------------------------------------------------------------------
    
    
    func appMovedToBackground() {
        print("App moved to background!")
        
        if let ac = alertController {
            ac.dismiss(animated: false, completion: nil)
        }
        
        // if the app moved to background and we have a safariViewController
        if let svc = safariViewController {
            let button = svc.navigationItem.rightBarButtonItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
                UIApplication.shared.sendAction((button?.action)!, to: button?.target, from: self, for: nil)
            }
            
        }
        
    }
    
    // ------------------------------------------------------------------------------------------
    // this is a hidden button that dismisses the safari view controller when the app goes to background
    // need to set the safariViewController to nil
    
    func dismiss() {
        safariViewController?.dismiss(animated: false, completion: nil)
        safariViewController = nil
    }
    
    // ------------------------------------------------------------------------------------------
    // this happens when the done button gets pressed
    // this is the other way we need to set the safariViewController to nil
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        safariViewController = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}


