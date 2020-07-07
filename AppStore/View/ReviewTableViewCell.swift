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
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    
    let currentUser = User.currentUser()
    
    func generateCell(_ review: Review) {
        
        profileImageView.layer.cornerRadius = 45/2
        reviewLabel.text = review.reviewString
        nameLabel.text = review.fullname
        
        profileImageView.sd_setImage(with: URL(string: review.profileImageUrl), placeholderImage: UIImage(named: "placeholder-person"))
        
        if backView != nil {
            
            backView.layer.borderWidth = 1
            backView.layer.borderColor = UIColor.systemGray4.cgColor
            
            itemNameLabel.text = review.name
            
            if review.imageUrls != nil && review.imageUrls.count > 0 {
                downloadImages(imageUrls: [review.imageUrls.first!]) { (images) in
                    self.itemImageView.image = images.first as? UIImage
                }
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
