//
//  ItemTableViewCell.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/26.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableImageView: UIImageView!
    @IBOutlet weak var tableNameLabel: UILabel!
    @IBOutlet weak var tablePriceLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
