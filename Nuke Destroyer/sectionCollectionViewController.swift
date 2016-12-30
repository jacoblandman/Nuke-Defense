//
//  sectionTableViewController.swift
//  JTL
//
//  Created by Jacob Landman on 12/6/16.
//  Copyright © 2016 Jacob Landman. All rights reserved.
//

import UIKit

class sectionCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    var data = [String]()
    var dataType: String = "Interests"
    var imageNames = [String]()
    var cellAccessory: UITableViewCellAccessoryType = .none
    var selectedIndexPath: IndexPath?
    var hidingNavigationBarManager: HidingNavigationBarManager?
    var originalNavController: UINavigationController?
    
    
    // METHODS
    // ------------------------------------------------------------------------------------------
    // in this function we can set the image alpha back to normal 
    // this simulates to the user that they clicked a cell
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        originalNavController?.isNavigationBarHidden = true
        navigationController?.isNavigationBarHidden = false
        
        hidingNavigationBarManager?.viewWillAppear(animated)
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        setImageNames()
        title = dataType
        
        // these data types have additional detailed views
        if (dataType == "Technical Experience" || dataType == "Education") { cellAccessory = .disclosureIndicator }
        
        // set the collection view layout
        collectionView?.backgroundColor = UIColor.white
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        setItemSize(for: layout)
        collectionView!.collectionViewLayout = layout
        
        hidingNavigationBarManager = HidingNavigationBarManager(viewController: self, scrollView: collectionView!)
        hidingNavigationBarManager?.onForegroundAction = .show
        hidingNavigationBarManager?.expansionResistance = 125
        
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
    
    func setItemSize(for layout: UICollectionViewFlowLayout) {
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
        
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        
        layout.minimumInteritemSpacing = 0.03 * viewWidth
        layout.minimumLineSpacing = 0.03 * viewWidth
        layout.sectionInset = UIEdgeInsets(top: 0.03 * viewHeight, left: 0.03 * viewWidth, bottom: 0.03 * viewHeight, right: 0.03 * viewWidth)
        
        layout.itemSize = CGSize(width: viewWidth - layout.sectionInset.left - layout.sectionInset.right,
                                 height: viewHeight - layout.sectionInset.bottom - layout.sectionInset.top - navHeight - tabHeight)
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! dataCollectionViewCell
        
        let type = dataType.lowercased()
        let name: String = type.replacingOccurrences(of: " ", with: "").appending(imageNames[indexPath.row].appending(".jpg"))
        print(name)
        let path = Bundle.main.path(forResource: name, ofType: "")!
        cell.dataImage.image = UIImage(contentsOfFile: path)
        cell.dataImage.alpha = 0.95
        
        // modify the label attributes
        cell.dataLabel.text = data[indexPath.row]
        cell.dataLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: cell.frame.height / 6)
        cell.dataLabel.textColor = UIColor.white
        
        // change the accessory type if there is another view with more detail (i.e. education and experience)
        if cellAccessory != .none {
            cell.disclosure.image = UIImage(named: "disclosureAccessory")
            if cellAccessory != .none { cell.isUserInteractionEnabled = true }
        }
        
        // let the user interact with the email cell to email me
        if (cell.dataLabel.text == "jlandman@tamu.edu") { cell.isUserInteractionEnabled = true }
        if (cell.dataLabel.text == "(817)-734-7833") { cell.isUserInteractionEnabled = true }
        
        // change the font size for publications because the label is long
        if dataType == "Publications" { cell.dataLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: cell.frame.height / 12) }
        
        return cell
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    // ------------------------------------------------------------------------------------------
    
    func loadData() {
        // load the text data that will be displayed in each cell of the tableView
        if let filePath = Bundle.main.path(forResource: dataType.replacingOccurrences(of: " ", with: ""), ofType: "txt") {
            do {
                let text = try String(contentsOfFile: filePath)
                data = text.components(separatedBy: "\n")
            } catch {
                // should present an alert controller here
                print("The data could not be loaded")
            }
        }
        // make sure no elements are empty strings
        data = data.filter { $0 != "" }
    }
    
    // ------------------------------------------------------------------------------------------
    // set the names that we use to load the images for each cell
    
    func setImageNames() {
        imageNames.removeAll()
        if (dataType == "Awards" || dataType == "Publications" || dataType == "Technical Experience" || dataType == "Personal Info" || dataType == "Education") {
            for i in 0 ..< data.count {
                imageNames.append(String(i))
            }
        } else {
            imageNames = data
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? dataCollectionViewCell {
            
            selectedIndexPath = indexPath
            
            // if the email cell was selected, open the mail app
            if cell.dataLabel.text == "jlandman@tamu.edu" {
                emailSelected()
                return
            }
            
            if cell.dataLabel.text == "(817)-734-7833" {
                phoneSelected()
                return
            }
            
            performSegue(withIdentifier: "segueToDetailView", sender: self)
        }
    }
    
    // ------------------------------------------------------------------------------------------
    // this function sets values for the detail view (if there is one)
    // the imageName to be loaded, the label and the detailed text need to be set
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToDetailView") {
            if let vc = segue.destination as? detailViewController {
                if let indexPath = selectedIndexPath {
                    // set the image name
                    let name: String = dataType.lowercased().replacingOccurrences(of: " ", with: "").appending(imageNames[indexPath.row])
                    vc.imageName = name.appending(".jpg")
                    
                    // set the detailed text
                    let text = loadText(withName: name)
                    vc.text = text
                    
                    // set the label
                    vc.label = data[indexPath.row]
                    
                    // set the date, which will be the views title
                    let fileName = dataType.replacingOccurrences(of: " ", with: "").appending("Dates")
                    vc.date = loadDates(forFile: fileName, forCellRowAt: indexPath)
                    
                    // set the title of the back item
                    let backItem = UIBarButtonItem()
                    backItem.title = "Back"
                    self.navigationItem.backBarButtonItem = backItem
                }
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func loadText(withName fileName: String) -> String {
        // don't need to unwrap the selected index path because at this point we know it has been set
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "txt") {
            do {
                let detailText = try String(contentsOfFile: filePath)
                return detailText
            } catch {
                // should present an alert controller here
                print("The detailed data could not be loaded")
            }
        }
        // set the detailed text to nothing if the file failed to load
        return ""
    }
    
    // ------------------------------------------------------------------------------------------
    // func to load the dates of education and tech experience
    
    func loadDates(forFile fileName: String, forCellRowAt indexPath: IndexPath ) -> String {
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "txt") {
            do {
                let text = try String(contentsOfFile: filePath)
                let dates = text.components(separatedBy: "\n")
                return dates[indexPath.row]
            } catch {
                print("The dates could not be loaded")
            }
        }
        
        // return an empty string as the date
        return ""
    }
    
    // ------------------------------------------------------------------------------------------
    
    func emailSelected() {
        let ac = UIAlertController(title: "jlandman@tamu.edu", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Email", style: .default) { [] _ in
            if let url = URL(string: "mailto:jlandman@tamu.edu") {
                UIApplication.shared.open(url, options: [:])
            }
        })
        
        present(ac, animated: true)
    }
    
    // ------------------------------------------------------------------------------------------
    
    func phoneSelected() {
        let ac = UIAlertController(title: "(817) 734-7833", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Call", style: .default) { [] _ in
            if let url = URL(string: "tel://8177347833") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
        })
        
        present(ac, animated: true)
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
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? dataCollectionViewCell
        UIView.animate(withDuration: 0.1) { [] in
            cell?.dataImage.alpha = 0.5
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? dataCollectionViewCell
        UIView.animate(withDuration: 0.1) { [] in
            cell?.dataImage.alpha = 0.95
        }
    }
    
}
