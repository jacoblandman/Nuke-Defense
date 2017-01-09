//
//  ResumeViewController.swift
//  JTL
//
//  Created by Jacob Landman on 11/30/16.
//  Copyright © 2016 Jacob Landman. All rights reserved.
//

import UIKit
import WebKit

class ResumeViewController: UIViewController, WKNavigationDelegate {

    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    var webView: WKWebView!
    
    
    // METHODS
    // ------------------------------------------------------------------------------------------
    
    override func loadView() {
        super.loadView()
        
        // create the webView for displaying the pdf
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the pdf
        if let pdf = Bundle.main.path(forResource: "Resume", ofType: "pdf") {
            let url = URL(fileURLWithPath: pdf)
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }

        // Do any additional setup after loading the view.
    }

    // ------------------------------------------------------------------------------------------
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ------------------------------------------------------------------------------------------
    
}
