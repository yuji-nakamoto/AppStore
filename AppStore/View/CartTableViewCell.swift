//
//  CartTableViewCell.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/28.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    
    func generateCell(_ item: Item) {
        nameLabel.text = item.name
        priceLabel.text = "¥\(String(item.price))"
        
        if item.imageLinks != nil && item.imageLinks.count > 0 {

            downloadImages(imageUrls: [item.imageLinks.first!]) { (images) in
                self.ImageView.image = images.first as? UIImage
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
