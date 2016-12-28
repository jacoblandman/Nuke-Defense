//
//  detailViewController.swift
//  JTL
//
//  Created by Jacob Landman on 12/7/16.
//  Copyright © 2016 Jacob Landman. All rights reserved.
//

import UIKit

class detailViewController: UIViewController {
    
    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailText: UITextView!
    @IBOutlet weak var detailLabel: UILabel!
    
    var imageName: String!
    var text: String!
    var label: String!
    var date: String!
    
    
    // METHODS
    // ------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // set the title of the view to the date of education or tech experience
        title = date
        
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.title = "Back"

    }
    
    // ------------------------------------------------------------------------------------------

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let path = Bundle.main.path(forResource: imageName, ofType: nil)!
        detailImage.image = UIImage(contentsOfFile: path)
        detailText.text = text
        detailText.font = UIFont.preferredFont(forTextStyle: .body)
        detailLabel.text = label
        detailLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: detailLabel.frame.height / 10)
        detailLabel.textColor = UIColor.white
        
        // nothing to swipe so we don't need to hide the navigation bar
        navigationController?.hidesBarsOnSwipe = false
        
    }
    
    // ------------------------------------------------------------------------------------------
    
}
