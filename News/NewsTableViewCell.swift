//
//  NewsTableViewCell.swift
//  News
//
//  Created by Nadiia Pavliuk on 3/30/18.
//  Copyright © 2018 Nadiia Pavliuk. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    var id = UUID()
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var descrTextView: UITextView!
    @IBOutlet var publishedAtLabel: UILabel!
    @IBOutlet var urlToImageView: UIImageView!
    @IBOutlet weak var autorLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

