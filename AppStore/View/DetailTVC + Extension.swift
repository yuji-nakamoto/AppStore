//
//  DetailTVC + Extension.swift
//  StoreApp
//
//  Created by yuji_nakamoto on 2020/07/08.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD

extension DetailTableViewController {
    
    //MARK: Setup UI
    
    func setupUI() {
        
        self.title = "商品の詳細"
        tableView.tableFooterView = UIView()
        reviewButton.layer.cornerRadius = 5
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    //MARK: Helper Function
    
    func dismissView() {
        
        textView.resignFirstResponder()
        textView.text = ""
        self.animationView.isHidden = !self.animationView.isHidden
        loadReviewFromFirestore()
        scrollToBottom()
    }
    
    func scrollToBottom() {
        
        let index = IndexPath(row: reviewArray.count, section: 0)
        tableView.scrollToRow(at: index, at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
    func hudError() {
        
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0)
    }
    
    func hudSuccess() {
        
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0)
    }
    
    func textViewHaveText() -> Bool {
        return textView.text != ""
    }
    
    func setupTextView() {
        
        textView.delegate = self
        pleaceholderLbl.isHidden = false
        
        let pleaceholderX: CGFloat = self.view.frame.size.width / 75
        let pleaceholderY: CGFloat = -50
        let pleaceholderWidth: CGFloat = textView.bounds.width - pleaceholderX
        let pleaceholderHeight: CGFloat = textView.bounds.height
        let pleaceholderFontSize = self.view.frame.size.width / 25
        
        pleaceholderLbl.frame = CGRect(x: pleaceholderX, y: pleaceholderY, width: pleaceholderWidth, height: pleaceholderHeight)
        pleaceholderLbl.text = "気に入ったことや、気に入らなかったこと"
        pleaceholderLbl.font = UIFont(name: "HelveticaNeue", size: pleaceholderFontSize)
        pleaceholderLbl.textColor = .systemGray4
        pleaceholderLbl.textAlignment = .left
        
        textView.addSubview(pleaceholderLbl)
    }
    
    func setupKeyboard() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            bottomConstraint.constant = 0
        } else {
            if #available(iOS 11.0, *) {
                bottomConstraint.constant = view.safeAreaInsets.bottom - keyboardViewEndFrame.height
            } else {
                bottomConstraint.constant = keyboardViewEndFrame.height
            }
            view.layoutIfNeeded()
        }
    }
}

extension DetailTableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let spacing = CharacterSet.whitespacesAndNewlines
        
        if !textView.text.trimmingCharacters(in: spacing).isEmpty {
            
            pleaceholderLbl.isHidden = true
        } else {
            pleaceholderLbl.isHidden = false
        }
    }
}
