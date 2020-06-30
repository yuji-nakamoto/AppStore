//
//  PurchasedTableViewCell.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/30.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class PurchasedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func generateCell(_ item: Item) {
        nameLabel.text = item.name
        
        if item.imageUrls != nil && item.imageUrls.count > 0 {

            downloadImages(imageUrls: [item.imageUrls.first!]) { (images) in
                self.itemImageView.image = images.first as? UIImage
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
