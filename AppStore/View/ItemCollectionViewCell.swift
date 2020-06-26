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
    
    func generateCell(_ category: Category) {
        nameLabel.text = category.name
        imageView.image = category.image
    }
    
}
