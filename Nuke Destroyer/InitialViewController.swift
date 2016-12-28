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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.landscapeOnly = false // or false to disable rotation
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addConstraints()
        
    }
    
    // ------------------------------------------------------------------------------------------

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ------------------------------------------------------------------------------------------
    
    func tappedIOSExperience(_ sender: Any) {
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
                UIApplication.shared.open(url, options: [:])
            } else {
                // if the facebook app isn't installed open in safari
                if let safariUrl = URL(string: "https://www.facebook.com/" + UID) {
                    UIApplication.shared.open(safariUrl, options: [:])
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
                UIApplication.shared.open(url, options: [:])
            } else {
                // if the facebook app isn't installed open in safari
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func tappedResume(_ sender: Any) {
        performSegue(withIdentifier: "segueToTab", sender: self)
    }
    
    // ------------------------------------------------------------------------------------------
    // create all the labels and offset them off the screen
    // they will be animated in when the view loads
    
    func makeLabels() {
        
        // the size of the screen is in points
        let sizeOfScreen: CGSize = UIScreen.main.bounds.size

        let xOffset: CGFloat = 20.0
        let yOffset: CGFloat = 30.0
        let viewWidth: CGFloat = sizeOfScreen.height
        let scaleFactor: CGFloat = 0.9
        
        print(sizeOfScreen.height)
        let labelHeight: CGFloat = scaleFactor * 0.33 * ((0.33 * sizeOfScreen.width) - yOffset)
        let labelStartingPosition: CGFloat = labelHeight + yOffset
        
        jacobLabel = UILabel()
        jacobLabel.frame = CGRect(x: xOffset, y: labelStartingPosition, width: viewWidth, height: labelHeight)
        jacobLabel.text = "Jacob"
        jacobLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: labelHeight)
        view.addSubview(jacobLabel)
        
        taylorLabel = UILabel()
        taylorLabel.frame = CGRect(x: xOffset, y: labelStartingPosition + 1 * (labelHeight - 2), width: viewWidth, height: labelHeight)
        taylorLabel.text = "Taylor"
        taylorLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: labelHeight)
        view.addSubview(taylorLabel)
        
        landmanLabel = UILabel()
        landmanLabel.frame = CGRect(x: xOffset, y: labelStartingPosition + 2 * (labelHeight - 2), width: viewWidth, height: labelHeight)
        landmanLabel.text = "Landman"
        landmanLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: labelHeight)
        view.addSubview(landmanLabel)
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
    
    func addConstraints() {
        
        // the size of the screen is in points
        
        let offsetFromBottom: CGFloat = 60
        let distanceBetween: CGFloat = 20
        let viewHeight = view.frame.width
        
        //print(navigationController?.view.frame.size)
        //self.view = navigationController?.view
        
        
        // iOS button constraints
        NSLayoutConstraint(item: resumeButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.5 * viewHeight).isActive = true
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
    
    // ------------------------------------------------------------------------------------------
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let constraints = navigationController?.view.constraints {
            for constraint in constraints {
                navigationController?.view.removeConstraint(constraint)
            }
        }
        
        for constraint in view.constraints {
            view.removeConstraint(constraint)
        }
        
        removeLabelsAndButtons()
    }
    
    // ------------------------------------------------------------------------------------------
    
    func removeLabelsAndButtons() {
        jacobLabel.removeFromSuperview()
        taylorLabel.removeFromSuperview()
        landmanLabel.removeFromSuperview()
        
        iosButton.removeFromSuperview()
        facebookButton.removeFromSuperview()
        resumeButton.removeFromSuperview()
        linkedinButton.removeFromSuperview()
    }
    
    
}
