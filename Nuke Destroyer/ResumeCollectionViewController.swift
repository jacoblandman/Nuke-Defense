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

class ResumeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    var sections = [String]()
    var selectedIndexPath: IndexPath?
    var selectedSection: String?
    var originalNavController: UINavigationController?
    
    
    // METHODS
    // ------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor.white
                
        // set the collection view layout
        setLayoutFor(collectionView!, with: collectionView!.frame.size)
        
        // load the labels for each cell in the table
        loadSections()
    }
    
    // ------------------------------------------------------------------------------------------
    
    func setLayoutFor(_ collectionView: UICollectionView, with size: CGSize) {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        if size.width > size.height {
            
            originalNavController?.isNavigationBarHidden = false
            navigationController?.isNavigationBarHidden = false
            
            layout.scrollDirection = .horizontal
            setItemSize(for: layout, with: size)
        } else {
            layout.scrollDirection = .vertical
            setItemSize(for: layout, with: size)
        }
        
        collectionView.collectionViewLayout = layout
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        setLayoutFor(collectionView!, with: size)
        collectionView!.reloadData()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // ------------------------------------------------------------------------------------------
    // in this function we can set the image alpha back to normal
    // this simulates to the user that they clicked a cell
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        originalNavController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
        
    }
    
    // ------------------------------------------------------------------------------------------

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ------------------------------------------------------------------------------------------

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // ------------------------------------------------------------------------------------------
    
    func setItemSize(for layout: UICollectionViewFlowLayout, with size: CGSize) {
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
        
        let viewWidth = size.width
        let viewHeight = size.height
        
        if viewWidth > viewHeight {
            layout.minimumInteritemSpacing = 0.03 * viewWidth
            layout.minimumLineSpacing = 0.03 * viewWidth
            layout.sectionInset = UIEdgeInsets(top: 0.03 * viewHeight, left: 0.03 * viewWidth, bottom: 0.03 * viewHeight, right: 0.03 * viewWidth)
            let height = viewHeight - layout.sectionInset.bottom - layout.sectionInset.top - navHeight - tabHeight - 10
            print(height)
            layout.itemSize = CGSize(width: viewWidth - layout.sectionInset.left - layout.sectionInset.right,
                                     height: viewHeight - layout.sectionInset.bottom - layout.sectionInset.top - navHeight - tabHeight)
        } else {
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1 , right: 1)
            layout.itemSize = CGSize(width: viewWidth - layout.sectionInset.left - layout.sectionInset.right,
                                     height: (viewHeight - navHeight - tabHeight - layout.minimumLineSpacing) / 3.0)
        }
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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ResumeSectionCollectionViewCell
        
        let name: String = sections[indexPath.row].replacingOccurrences(of: " ", with: "").appending(".jpg")
        cell.sectionImage.image = UIImage(named: name)
        
        // modify the label attributes
        cell.sectionLabel.text = sections[indexPath.row]
        cell.sectionLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: cell.frame.height / 6)
        cell.sectionLabel.textColor = UIColor.white
        
        cell.disclosure.image = UIImage(named: "disclosureAccessory")
        
        return cell
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedSection = sections[indexPath.item]
        
        // load the section view table
        if let sectionType = SectionType(rawValue: indexPath.row) {
            segueToNextView(sectionType: sectionType)
        } else {
            print("The section Type is wrong when selecting a row")
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
            if let vc = segue.destination as? sectionCollectionViewController {
                vc.originalNavController = originalNavController
                if let section = selectedSection {
                    vc.dataType = section
                } else {
                    print("When preparing to segue, the section isn't set")
                }
            } else {
                print("When preparing to segue, the destination isn't correct")
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ResumeSectionCollectionViewCell
        UIView.animate(withDuration: 0.1) { [] in
            cell?.sectionImage.alpha = 0.5
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ResumeSectionCollectionViewCell
        UIView.animate(withDuration: 0.1) { [] in
            cell?.sectionImage.alpha = 0.95
        }
    }
}
