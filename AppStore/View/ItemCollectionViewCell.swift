//
//  ItemCollectionViewCell.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/26.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func generateCell(_ item: Item) {
        nameLabel.text = item.name
        
        if item.imageLinks != nil && item.imageLinks.count > 0 {

            downloadImages(imageUrls: [item.imageLinks.first!]) { (images) in
                self.imageView.image = images.first as? UIImage
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.image = UIImage(named: "Placeholder-image")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage(named: "Placeholder-image")
    }
    
}
