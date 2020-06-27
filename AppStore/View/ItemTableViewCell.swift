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
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    func generateCell(_ item: Item) {
        nameLabel.text = item.name
        priceLabel.text = "¥\(String(item.price))"
        descriptionLabel.text = item.descriprion
        
        if item.imageLinks != nil && item.imageLinks.count > 0 {

            downloadImages(imageUrls: [item.imageLinks.first!]) { (images) in
                self.tableImageView.image = images.first as? UIImage
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tableImageView.image = UIImage(named: "Placeholder-image")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tableImageView.image = UIImage(named: "Placeholder-image")
    }

}
