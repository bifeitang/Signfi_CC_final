//
//  StudentPresenceTableViewCell.swift
//  complete-view
//
//  Created by Sunshine on 2018/5/8.
//  Copyright © 2018年 Sunshine. All rights reserved.
//

import UIKit

class StudentPresenceTableViewCell: UITableViewCell {

    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var isPresent: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
