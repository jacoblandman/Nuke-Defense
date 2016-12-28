//
//  sectionTableViewController.swift
//  JTL
//
//  Created by Jacob Landman on 12/6/16.
//  Copyright © 2016 Jacob Landman. All rights reserved.
//

import UIKit

class sectionTableViewController: UITableViewController {

    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    var data = [String]()
    var dataType: String = "Interests"
    var imageNames = [String]()
    var cellAccessory: UITableViewCellAccessoryType = .none
    var selectedIndexPath: IndexPath?
    var hidingNavigationBarManager: HidingNavigationBarManager?
    
    
    // METHODS
    // ------------------------------------------------------------------------------------------
    // in this function we can set the image alpha back to normal 
    // this simulates to the user that they clicked a cell
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = selectedIndexPath {
            if let cell = tableView.cellForRow(at: indexPath) as? dataTableViewCell {
               cell.dataImage.alpha = 0.95
            }
        }
        
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
        
        hidingNavigationBarManager = HidingNavigationBarManager(viewController: self, scrollView: tableView)
        hidingNavigationBarManager?.onForegroundAction = .show
        hidingNavigationBarManager?.expansionResistance = 125
        
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
        // nav height should be 44
        let navHeight: CGFloat
        if let nc = navigationController {
            navHeight = nc.navigationBar.frame.size.height
        } else {
            print("The navigation controller is nil")
            navHeight = 0.0
        }
        
        var scale : CGFloat = 3.0
        if data.count < 3 { scale = CGFloat(data.count) }
        
        return (tableView.frame.size.height - navHeight) / scale
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // nav height should be 44
        let navHeight: CGFloat
        if let nc = navigationController {
            navHeight = nc.navigationBar.frame.size.height
        } else {
            print("The navigation controller is nil")
            navHeight = 0.0
        }
        
        var scale : CGFloat = 3.0
        if data.count < 3 { scale = CGFloat(data.count) }
        
        return (tableView.frame.size.height  - navHeight) / scale
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath) as! dataTableViewCell
        
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
        cell.accessoryType = cellAccessory
        if cellAccessory != .none { cell.isUserInteractionEnabled = true }
        
        // let the user interact with the email cell to email me
        if (cell.dataLabel.text == "jlandman@tamu.edu") { cell.isUserInteractionEnabled = true }
        if (cell.dataLabel.text == "(817)-734-7833") { cell.isUserInteractionEnabled = true }
        
        // change the font size for publications because the label is long
        if dataType == "Publications" { cell.dataLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: cell.frame.height / 12) }
        
        return cell
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? dataTableViewCell {
            
            // change the alpha value so the user sees they selected the cell
            cell.dataImage.alpha = 0.5
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if let indexPath = self.selectedIndexPath {
                if let cell = self.tableView.cellForRow(at: indexPath) as? dataTableViewCell {
                    cell.dataImage.alpha = 0.95
                }
            }
        })
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            if let indexPath = self.selectedIndexPath {
                if let cell = self.tableView.cellForRow(at: indexPath) as? dataTableViewCell {
                    cell.dataImage.alpha = 0.95
                }
            }
        })
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
