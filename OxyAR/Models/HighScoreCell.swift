//
//  HighScoreCell.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 4/6/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import UIKit

class HighScoreCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
