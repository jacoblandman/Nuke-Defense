//
//  ResumeTableViewController.swift
//  JTL
//
//  Created by Jacob Landman on 11/30/16.
//  Copyright © 2016 Jacob Landman. All rights reserved.
//

import UIKit
import CoreImage

enum SectionType: Int {
    case personalInfo
    case technicalExperience
    case languages
    case education
    case awards
    case interests
    case publications
}

class ResumeTableViewController: UITableViewController {

    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    var sections = [String]()
    var selectedIndexPath: IndexPath?
    var hidingNavigationBarManager: HidingNavigationBarManager?
    
    
    // METHODS
    // ------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // load the labels for each cell in the table
        loadSections()
        
        hidingNavigationBarManager = HidingNavigationBarManager(viewController: self, scrollView: tableView)
        
        if let tabBar = tabBarController?.tabBar {
            print("tab bar is added")
            hidingNavigationBarManager?.manageBottomBar(tabBar)
            
        }
        
        hidingNavigationBarManager?.onForegroundAction = .show
        hidingNavigationBarManager?.expansionResistance = 125
    }
    
    // ------------------------------------------------------------------------------------------
    // in this function we can set the image alpha back to normal
    // this simulates to the user that they clicked a cell
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        //navigationController?.hidesBarsOnSwipe = true

        if let indexPath = selectedIndexPath {
            if let cell = tableView.cellForRow(at: indexPath) as? ResumeSectionTableViewCell {
                cell.sectionImage.alpha = 0.95
            } else {
                print("When the view is appearing, the cell isn't the correct class")
            }
        }
        
        navigationController?.hidesBarsOnSwipe = false
        
        hidingNavigationBarManager?.viewWillAppear(animated)
    }
    
    // ------------------------------------------------------------------------------------------

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ------------------------------------------------------------------------------------------

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // tab height should be 49
        let tabHeight: CGFloat
        if let tb = tabBarController {
            tabHeight = tb.tabBar.frame.size.height
        } else {
            print("The tab controller is nil")
            tabHeight = 49
        }

        // nav height shoudl be 44
        let navHeight: CGFloat
        if let nc = navigationController {
            navHeight = nc.navigationBar.frame.size.height
        } else {
            print("the nav controller is nil")
            navHeight = 44
        }
        
        return (tableView.frame.size.height - tabHeight - navHeight) / 3.0
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // tab height should be 49
        let tabHeight: CGFloat
        if let tb = tabBarController {
            tabHeight = tb.tabBar.frame.size.height
        } else {
            print("The tab controller is nil")
            tabHeight = 49
        }
        
        // nav height shoudl be 44
        let navHeight: CGFloat
        if let nc = navigationController {
            navHeight = nc.navigationBar.frame.size.height
        } else {
            print("The nav controller is nil")
            navHeight = 44
        }
        
        return (tableView.frame.size.height - tabHeight - navHeight) / 3.0
    }
    
    // ------------------------------------------------------------------------------------------
    // load the text data that will be displayed in each cell of the tableView
    
    func loadSections() {
        sections.append("Personal Info")
        sections.append("Technical Experience")
        sections.append("Languages")
        sections.append("Education")
        sections.append("Awards")
        sections.append("Interests")
        sections.append("Publications")
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ResumeSectionTableViewCell
        
        let name: String = sections[indexPath.row].replacingOccurrences(of: " ", with: "").appending(".jpg")
        cell.sectionImage.image = UIImage(named: name)
        
        // modify the label attributes
        cell.sectionLabel.text = sections[indexPath.row]
        cell.sectionLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: cell.frame.height / 6)
        cell.sectionLabel.textColor = UIColor.white
        
        // it turns out that performance is suffering from filtering the image on the fly
        // instead we will do image filtering before
        // this isn't surprising since we have to create additional CIImage and CGImages
        //filterCellImage(cell: cell)
        
        return cell
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ResumeSectionTableViewCell {
            
            // change the alpha value so the user sees they selected the cell
            cell.sectionImage.alpha = 0.5
            selectedIndexPath = indexPath
            
            // load the section view table
            if let sectionType = SectionType(rawValue: indexPath.row) {
                segueToNextView(sectionType: sectionType)
            } else {
                print("The section Type is wrong when selecting a row")
            }
        } else {
            print("The cell is not the correct type when selecting")
        }
        
        
    }
    
    // ------------------------------------------------------------------------------------------
    // this function doesn't seem necessary anymore because all views have the same segue
    // orifinally they were going to have different segues
    // i'll just leave the function here for now
    
    func segueToNextView(sectionType: SectionType) {
        
        switch sectionType {
            case .personalInfo:
                performSegue(withIdentifier: "segueToSection", sender: self)
            
            case .technicalExperience:
                performSegue(withIdentifier: "segueToSection", sender: self)
            
            case .languages:
                performSegue(withIdentifier: "segueToSection", sender: self)
            
            case .education:
                performSegue(withIdentifier: "segueToSection", sender: self)
            
            case .awards:
                performSegue(withIdentifier: "segueToSection", sender: self)
            
            case .interests:
                performSegue(withIdentifier: "segueToSection", sender: self)
            
            case .publications:
                performSegue(withIdentifier: "segueToSection", sender: self)
        }

    }
    
    // ------------------------------------------------------------------------------------------
    // this function sets values for the section table view
    // the dataType gets set, which informs the next view what text file to look at when loading the data
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToSection") {
            if let vc = segue.destination as? sectionTableViewController {
                if let indexPath = selectedIndexPath {
                    vc.dataType = sections[indexPath.row]
                } else {
                    print("When preparing to segue, the index path isn't set")
                }
            } else {
                print("When preparing to segue, the destination isn't correct")
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        hidingNavigationBarManager?.viewDidLayoutSubviews()
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hidingNavigationBarManager?.viewWillDisappear(animated)
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        hidingNavigationBarManager?.shouldScrollToTop()
        
        return true
    }
    
    // ------------------------------------------------------------------------------------------
}
