//
//  ProfileTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/28.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var profileImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        profileImageButton.layer.cornerRadius = 5
        
        loadUserInfo()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUserInfo()
    }
    
    private func setupUI() {
        
        profileImageView.layer.cornerRadius = 35
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
    }
    
    //MARK: UpdateUI
    
    private func loadUserInfo() {
        
        if User.currentUser() != nil {
            
            let currentUser = User.currentUser()!
            if currentUser.firstName == "" && currentUser.lastName == "" {
                
                userNameLabel.text = ""
                descriptionLabel.text = "買い物を続けるには\nアドレス帳の管理を行って下さい。"
                return
            }
            descriptionLabel.text = ""
            userNameLabel.text = "こんにちは、\(currentUser.fullName)さん"
        }
    }
    
    //MARK: IBAction
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        let currentUser = User.currentUser()!
        
        let alert: UIAlertController = UIAlertController(title: "\(currentUser.fullName)さん", message: "ログアウトしてもよろしいですか？", preferredStyle: .actionSheet)
        let logout: UIAlertAction = UIAlertAction(title: "ログアウト", style: UIAlertAction.Style.default) { (alert) in
            
            User.logoutUser { (error) in
                if error != nil {
                    print("error logout user: \(error!.localizedDescription)")
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
                self.present(loginVC, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (alert) in
        }
        alert.addAction(logout)
        alert.addAction(cancel)
        self.present(alert,animated: true,completion: nil)
    }
    
    @IBAction func profileImageButtonPressed(_ sender: Any) {
        
        
    }
    
    
    @IBAction func tapProfileImage(_ sender: Any) {
        
       
    }
    
    @IBAction func tapHeaderImage(_ sender: Any) {
        
      
    }
    
}
