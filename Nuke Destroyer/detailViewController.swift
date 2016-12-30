//
//  detailViewController.swift
//  JTL
//
//  Created by Jacob Landman on 12/7/16.
//  Copyright © 2016 Jacob Landman. All rights reserved.
//

import UIKit

class detailViewController: UICollectionViewController {
    
    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailText: UILabel!

    
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
        
        // set the collection view layout
        setLayoutFor(collectionView!, with: collectionView!.frame.size)
        
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.title = "Back"

    }
    
    // ------------------------------------------------------------------------------------------
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // ------------------------------------------------------------------------------------------
    
    func setLayoutFor(_ collectionView: UICollectionView, with size: CGSize) {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        if size.width > size.height {
            
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
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0.03 * viewHeight, left: 0.03 * viewWidth, bottom: 0.03 * viewHeight, right: 0.03 * viewWidth)
        
        if viewWidth > viewHeight {
            layout.itemSize = CGSize(width: (viewWidth - layout.sectionInset.left - layout.sectionInset.right - layout.minimumLineSpacing) / 2,
                                     height: viewHeight - layout.sectionInset.bottom - layout.sectionInset.top - navHeight - tabHeight)
        } else {
            layout.itemSize = CGSize(width: (viewWidth - layout.sectionInset.left - layout.sectionInset.right - layout.minimumLineSpacing),
                                     height: (viewHeight - layout.sectionInset.bottom - layout.sectionInset.top - navHeight - tabHeight) / 2)
        }
    }
    
    // ------------------------------------------------------------------------------------------

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! detailCollectionViewCell
        
        if (indexPath.item == 0) {
            cell.detailImage.image = UIImage(named: imageName)
            
            // modify the label attributes
            cell.detailLabel.text = label
            cell.detailLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: cell.frame.height / 10)
            cell.detailLabel.textColor = UIColor.white
            
        } else {
            
            if !(text.contains("Major")) {
                cell.detailLabel.textAlignment = .left
            }
            cell.detailLabel.text = text
            cell.detailLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        }
        
        return cell
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ------------------------------------------------------------------------------------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // nothing to swipe so we don't need to hide the navigation bar
        navigationController?.hidesBarsOnSwipe = false
        
    }
    
    // ------------------------------------------------------------------------------------------
    
    
    
    
}
