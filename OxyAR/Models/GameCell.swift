//
//  SessionCell.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 4/1/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import UIKit

class GameCell: UITableViewCell {

    @IBOutlet weak var sessionName: UILabel!
    
    @IBAction func joinBtn(_ sender: Any) {
        print("join btn")
    }
    
    var game: NetworkGame!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
