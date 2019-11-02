//
//  LiveTableViewCell.swift
//  YingKe
//
//  Created by 邓康大 on 2017/6/12.
//  Copyright © 2017年 邓康大. All rights reserved.
//

import UIKit

class LiveTableViewCell: UITableViewCell {

    @IBOutlet weak var imgPor: UIImageView!
    @IBOutlet weak var labelViewers: UILabel!
    @IBOutlet weak var imgBigPor: UIImageView!
    @IBOutlet weak var labelNick: UILabel!
    @IBOutlet weak var labelAddr: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
