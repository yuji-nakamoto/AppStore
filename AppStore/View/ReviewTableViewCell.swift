//
//  ReviewTableViewCell.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/07/02.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    
    func generaterCell(_ review: Review) {
        
        profileImageView.layer.cornerRadius = 45/2
        reviewLabel.text = review.reviewString
        nameLabel.text = review.fullname
        
        downloadImages(imageUrls: [review.profileImageUrl]) { (images) in
            self.profileImageView.image = images.first as? UIImage
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
