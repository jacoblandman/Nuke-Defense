//
//  InitialViewController.swift
//  JTL
//
//  Created by Jacob Landman on 11/29/16.
//  Copyright © 2016 Jacob Landman. All rights reserved.
//

import UIKit
import SafariServices
import AudioToolbox
import AVFoundation

class InitialViewController: UIViewController, UINavigationControllerDelegate {

    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    var jacobLabel: UILabel!
    var taylorLabel: UILabel!
    var landmanLabel: UILabel!
    var nameLabel: UILabel!
    
    var iosButton: UIButton!
    var facebookButton: UIButton!
    var linkedinButton: UIButton!
    var resumeButton: UIButton!
        
    var safariVC: SFSafariViewController?
    
    
    // METHODS
    // ------------------------------------------------------------------------------------------
    // This method only gets called once. We will make the labels here and add them as subviews
    
    override func loadView() {
        super.loadView()
        
        makeButtons()
        makeLabels()
    }
    
    // ------------------------------------------------------------------------------------------
    // here I will add the auto layout constraints now that the buttons are created
    // the labels are already constrained by the CGRects
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
        if (UIApplication.shared.statusBarOrientation != .landscapeLeft && UIApplication.shared.statusBarOrientation != .landscapeRight) {
            let value = UIDeviceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        setConstraintsForView(with: view.frame.size)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.landscapeOnly = true
    }

    // ------------------------------------------------------------------------------------------
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        setConstraintsForView(with: size)
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // ------------------------------------------------------------------------------------------

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ------------------------------------------------------------------------------------------
    
    func tappedIOSExperience(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.landscapeOnly = false
        performSegue(withIdentifier: "segueToIOS", sender: self)
        
    }
    
    // ------------------------------------------------------------------------------------------
    // if the user taps the facebook button, they will be redirected to my facebook
    
    func tappedFacebook(_ sender: Any) {
        let UID: String = "1372129908"
        let URLString = "fb://profile/" + UID
        
        if let url = URL(string: URLString) {
            if UIApplication.shared.canOpenURL(url) {
                // if the app is installed open it there
                print("facebook is installed")
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                // if the facebook app isn't installed open in safari
                if let safariUrl = URL(string: "https://www.facebook.com/" + UID) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(safariUrl, options: [:])
                    } else {
                        print("running openURL")
                        UIApplication.shared.openURL(safariUrl)
                    }
                }
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    // if the user taps the linkedIn button, they will be redirected to my linkedIn profile
    
    func tappedLinkedIn(_ sender: Any) {
        let UID: String = "25216973"
        let URLString = "https://www.linkedin.com/in/jacob-landman-" + UID
        
        if let url = URL(string: URLString) {
            if UIApplication.shared.canOpenURL(url) {
                // if the app is installed open it there
                print("linkedin is installed")
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                // if the facebook app isn't installed open in safari
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func tappedResume(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.landscapeOnly = false
        performSegue(withIdentifier: "segueToTab", sender: self)
    }
    
    // ------------------------------------------------------------------------------------------
    // create all the labels and offset them off the screen
    // they will be animated in when the view loads
    
    func makeLabels() {
        
        // the size of the screen is in points
        let sizeOfScreen: CGSize = UIScreen.main.bounds.size

        let xOffset: CGFloat = 20.0
        let yOffset: CGFloat = 50.0
        let viewWidth: CGFloat = sizeOfScreen.width
        let scaleFactor: CGFloat = 0.9
        
        let labelHeight: CGFloat = scaleFactor * ((0.33 * sizeOfScreen.height) - yOffset)
        let labelStartingPosition: CGFloat = labelHeight + yOffset
        
        nameLabel = UILabel()
        nameLabel.frame = CGRect(x: xOffset, y: labelStartingPosition, width: viewWidth - 2.0 * xOffset, height: labelHeight)
        nameLabel.text = "Jacob Taylor Landman"
        nameLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: labelHeight)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.frame = CGRect(x: xOffset, y: yOffset, width: viewWidth - 2.0 * xOffset, height: nameLabel.font.pointSize)
        nameLabel.textAlignment = .center
        view.addSubview(nameLabel)
    }
    
    // ------------------------------------------------------------------------------------------
    // add all the buttons to the view
    
    func makeButtons() {
        
        // make the buttons of type .system so that the text highlights when tapped
        
        iosButton = UIButton(type: .system) as UIButton
        iosButton.translatesAutoresizingMaskIntoConstraints = false
        iosButton.setTitle("  iOS Experience  ", for: .normal)
        iosButton.setTitleColor(self.view.tintColor, for: .normal)
        iosButton.addTarget(self, action: #selector(tappedIOSExperience(_:)), for: .touchUpInside)
        iosButton.layer.borderWidth = 1.0
        iosButton.layer.borderColor = self.view.tintColor.cgColor
        iosButton.layer.cornerRadius = 10
        view.addSubview(iosButton)
        
        facebookButton = UIButton(type: .system) as UIButton
        facebookButton.translatesAutoresizingMaskIntoConstraints = false
        facebookButton.setTitle("Facebook", for: .normal)
        facebookButton.setTitleColor(self.view.tintColor, for: .normal)
        facebookButton.addTarget(self, action: #selector(tappedFacebook(_:)), for: .touchUpInside)
        facebookButton.showsTouchWhenHighlighted = true
        facebookButton.layer.borderWidth = 1.0
        facebookButton.layer.borderColor = self.view.tintColor.cgColor
        facebookButton.layer.cornerRadius = 10
        view.addSubview(facebookButton)
        
        linkedinButton = UIButton(type: .system) as UIButton
        linkedinButton.translatesAutoresizingMaskIntoConstraints = false
        linkedinButton.setTitle("LinkedIn", for: .normal)
        linkedinButton.setTitleColor(self.view.tintColor, for: .normal)
        linkedinButton.addTarget(self, action: #selector(tappedLinkedIn(_:)), for: .touchUpInside)
        linkedinButton.showsTouchWhenHighlighted = true
        linkedinButton.layer.borderWidth = 1.0
        linkedinButton.layer.borderColor = self.view.tintColor.cgColor
        linkedinButton.layer.cornerRadius = 10
        view.addSubview(linkedinButton)
        
        resumeButton = UIButton(type: .system) as UIButton
        resumeButton.translatesAutoresizingMaskIntoConstraints = false
        let eAcute: Character = "\u{E9}"
        resumeButton.setTitle("Resum".appending(String(eAcute)), for: .normal)
        resumeButton.setTitleColor(self.view.tintColor, for: .normal)
        resumeButton.addTarget(self, action: #selector(tappedResume(_:)), for: .touchUpInside)
        resumeButton.showsTouchWhenHighlighted = true
        resumeButton.layer.borderWidth = 1.0
        resumeButton.layer.borderColor = self.view.tintColor.cgColor
        resumeButton.layer.cornerRadius = 10
        view.addSubview(resumeButton)
        
    }
    
    // ------------------------------------------------------------------------------------------
    // add all the constraints for the buttons and labels
    
    func setConstraintsForView(with size: CGSize) {
        
        view.removeConstraints(view.constraints)
        
        let viewWidth = size.width
        let viewHeight = size.height
        
        if viewWidth > viewHeight {
            // the size of the screen is in points
            let buttonWidth: CGFloat = viewWidth * 0.25
            let buttonHeight: CGFloat = viewHeight * 0.6 * 0.66
            let yDistance: CGFloat = ( viewHeight - 2 * buttonHeight ) / 3
            let xDistance: CGFloat = ( viewWidth - 2 * buttonWidth ) / 3
            
            // resume button constraints
            NSLayoutConstraint(item: resumeButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.33 * viewHeight + yDistance).isActive = true
            NSLayoutConstraint(item: resumeButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: xDistance).isActive = true
            NSLayoutConstraint(item: resumeButton, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.5, constant: -1.5 * xDistance).isActive = true
            NSLayoutConstraint(item: resumeButton, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.5 * 0.66, constant: -1.5 * yDistance).isActive = true
            
            // ios button constraints
            NSLayoutConstraint(item: iosButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.33 * viewHeight + yDistance).isActive = true
            NSLayoutConstraint(item: iosButton, attribute: .leading, relatedBy: .equal, toItem: resumeButton, attribute: .trailing, multiplier: 1.0, constant: xDistance).isActive = true
            NSLayoutConstraint(item: iosButton, attribute: .width, relatedBy: .equal, toItem: resumeButton, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: iosButton, attribute: .height, relatedBy: .equal, toItem: resumeButton, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
            
            // facebook button constraints
            NSLayoutConstraint(item: facebookButton, attribute: .top, relatedBy: .equal, toItem: resumeButton, attribute: .bottom, multiplier: 1.0, constant: yDistance).isActive = true
            NSLayoutConstraint(item: facebookButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: xDistance).isActive = true
            NSLayoutConstraint(item: facebookButton, attribute: .width, relatedBy: .equal, toItem: resumeButton, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: facebookButton, attribute: .height, relatedBy: .equal, toItem: resumeButton, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
            
            // linkedin button constraints
            NSLayoutConstraint(item: linkedinButton, attribute: .top, relatedBy: .equal, toItem: iosButton, attribute: .bottom, multiplier: 1.0, constant: yDistance).isActive = true
            NSLayoutConstraint(item: linkedinButton, attribute: .leading, relatedBy: .equal, toItem: facebookButton, attribute: .trailing, multiplier: 1.0, constant: xDistance).isActive = true
            NSLayoutConstraint(item: linkedinButton, attribute: .width, relatedBy: .equal, toItem: resumeButton, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: linkedinButton, attribute: .height, relatedBy: .equal, toItem: resumeButton, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
        } else {
            
            let offsetFromBottom: CGFloat = 60
            let distanceBetween: CGFloat = 20
            
            // iOS button constraints
            NSLayoutConstraint(item: resumeButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.5 * view.frame.height).isActive = true
            NSLayoutConstraint(item: resumeButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
            
            // facebook button constraints
            NSLayoutConstraint(item: facebookButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: facebookButton, attribute: .width, relatedBy: .equal, toItem: resumeButton, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: facebookButton, attribute: .height, relatedBy: .equal, toItem: resumeButton, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: facebookButton, attribute: .top, relatedBy: .equal, toItem: resumeButton, attribute: .bottom, multiplier: 1.0, constant: distanceBetween).isActive = true
            
            // linkedin button constraints
            NSLayoutConstraint(item: linkedinButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: linkedinButton, attribute: .width, relatedBy: .equal, toItem: resumeButton, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: linkedinButton, attribute: .height, relatedBy: .equal, toItem: resumeButton, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: linkedinButton, attribute: .top, relatedBy: .equal, toItem: facebookButton, attribute: .bottom, multiplier: 1.0, constant: distanceBetween).isActive = true
            
            // resume button constraints
            NSLayoutConstraint(item: iosButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: iosButton, attribute: .width, relatedBy: .equal, toItem: resumeButton, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: iosButton, attribute: .height, relatedBy: .equal, toItem: resumeButton, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: iosButton, attribute: .top, relatedBy: .equal, toItem: linkedinButton, attribute: .bottom, multiplier: 1.0, constant: distanceBetween).isActive = true
            NSLayoutConstraint(item: iosButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -offsetFromBottom).isActive = true
        }
        
    }
        
    // ------------------------------------------------------------------------------------------
    // this function sets values for the section table view
    // the dataType gets set, which informs the next view what text file to look at when loading the data
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToTab") {
            if let tabBar = segue.destination as? UITabBarController {
                if let navc = tabBar.viewControllers?[0] as? UINavigationController {
                    if let vc = navc.topViewController as? ResumeCollectionViewController {
                        vc.originalNavController = navigationController
                    }
                }
            }
        }
    }
    
}
