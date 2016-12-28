//
//  ResumeSectionTableViewCell.swift
//  JTL
//
//  Created by Jacob Landman on 12/1/16.
//  Copyright © 2016 Jacob Landman. All rights reserved.
//

import UIKit

class ResumeSectionTableViewCell: UITableViewCell {
    
    // PARAMETERS
    // ------------------------------------------------------------------------------------------
    @IBOutlet weak var sectionImage: UIImageView!
    @IBOutlet weak var sectionLabel: UILabel!
    
    
    // METHODS
    // ------------------------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // ------------------------------------------------------------------------------------------
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // ------------------------------------------------------------------------------------------

}
