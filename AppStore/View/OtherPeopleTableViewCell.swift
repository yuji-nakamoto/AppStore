//
//  OtherPeopleTableViewCell.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/07/07.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class OtherPeopleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    func setupUserInfo() {
        
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.systemBackground.cgColor
        profileImageView.layer.cornerRadius = 35
        usernameLabel.text = user?.fullName
        if user?.headerImageUrl != nil {
            headerImageView.sd_setImage(with: URL(string: user!.headerImageUrl), completed: nil)

        }
        if user?.profileImageUrl != nil {
            profileImageView.sd_setImage(with: URL(string: user!.profileImageUrl), completed: nil)
            
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
