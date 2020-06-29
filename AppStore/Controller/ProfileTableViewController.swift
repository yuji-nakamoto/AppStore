//
//  ProfileTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/28.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import FirebaseStorage
import JGProgressHUD
import SDWebImage
import NVActivityIndicatorView

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var profileImageButton: UIButton!
    
    var profileImage: UIImage?
    var headerImage: UIImage?
    var hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView!
    let currentUser = User.currentUser()!
    let picker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        profileImageButton.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUserInfo()
        setupUI()
    }
    
    
    //MARK: Setup UI
    
    private func setupUI() {
        
        profileImageView.layer.cornerRadius = 35
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballClipRotatePulse, color: UIColor(named: "original yellow"), padding: nil)
    }
    
    //MARK: load User
    
    private func loadUserInfo() {
        
        if currentUser.profileImageUrl != "" {
            profileImageView.sd_setImage(with: URL(string: currentUser.profileImageUrl), completed: nil)
        }
        
        if currentUser.headerImageUrl != "" {
            headerImageView.sd_setImage(with: URL(string: currentUser.headerImageUrl), completed: nil)
        }
        
        if User.currentUser() != nil {
            
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
        logoutUser()
    }
    
    @IBAction func profileImageButtonPressed(_ sender: Any) {
        saveProfileImages()
    }
    
    @IBAction func tapProfileImage(_ sender: Any) {
        picker.allowsEditing = false
        pickerDelegate()
    }
    
    @IBAction func tapHeaderImage(_ sender: Any) {
        
        picker.allowsEditing = true
        pickerDelegate()
    }
    
    //MARL: logout
    
    private func logoutUser() {
        
        let alert: UIAlertController = UIAlertController(title: currentUser.fullName, message: "ログアウトしてもよろしいですか？", preferredStyle: .actionSheet)
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
    
    //MARK: Save ProfileImages
    
    private func saveProfileImages() {
        
        if profileImage == nil && headerImage == nil {
            self.hud.textLabel.text = "画像を選択して下さい"
            self.hudError()
            return
        }
        
        if profileImage != nil {
            
            showLoadingIndicator()
            uploadProfileImages(image: profileImage) { (profileUrl) in
                
                let withValues = [PROFILEIMAGEURL: profileUrl]
                
                updateCurrentUserFierstore(withValues: withValues) { (error) in
                    
                    if error == nil {
                       self.hideLoadingIndicator()
                       self.hud.textLabel.text = "プロフィール画像を設定しました"
                       self.hudSuccess()
                       self.profileImage = nil
                    }
                }
            }
        }
        if self.headerImage != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                
                self.showLoadingIndicator()
                uploadHeaderImages(image: self.headerImage) { (headerUrl) in
                    
                    let withValues = [HEADERIMAGEURL: headerUrl]
                    
                    updateCurrentUserFierstore(withValues: withValues) { (error) in
                        
                        if error == nil {
                            
                          self.hideLoadingIndicator()
                          self.hud.textLabel.text = "ヘッダー画像を設定しました"
                          self.hudSuccess()
                          self.headerImage = nil
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Picker Delegate
    
    private func pickerDelegate() {
        
        self.view.endEditing(true)
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.present(picker, animated:  true, completion: nil)
    }
    
    //MARK: Helper Function
    
    private func hudError() {
        
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0)
    }
    
    private func hudSuccess() {
        
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0)
    }
    
    //MARK: Activity Indicator
    
    private func showLoadingIndicator() {
        
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
    
}

extension ProfileTableViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.editedImage] as? UIImage {
            
            headerImage = selectedImage
            headerImageView.image = selectedImage
            picker.dismiss(animated: true, completion: nil)
            return
        }
        if let selectedImage = info[.originalImage] as? UIImage {
            
            profileImage = selectedImage
            profileImageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
