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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!
    
    func generateCell(_ item: Item) {
        nameLabel.text = item.name
        priceLabel.text = "¥\(String(item.price))"
        reviewCountLabel.text = String(item.reviewCount)
        
        if item.imageUrls != nil && item.imageUrls.count > 0 {
            downloadImages(imageUrls: [item.imageUrls.first!]) { (images) in
                DispatchQueue.main.async {
                    self.tableImageView.image = images.first as? UIImage
                }
            }
        }
    }
    
}
