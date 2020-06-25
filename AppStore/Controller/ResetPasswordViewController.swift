//
//  ResetPasswordViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/26.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: IBAction
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        
        if textFieldHaveText() == true {
            
            resetPassword()
        } else {
            hud.textLabel.text = "メールアドレスを入力してください"
            hudError()
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Reset password
    
    private func resetPassword() {
        
        showLoadingIndicator()
        User.resetPassword(email: emailTextField.text!) { (error) in
            
            if error != nil {
                self.hud.textLabel.text = error!.localizedDescription
                self.hudError()
                self.hideLoadingIndicator()
                return
            }
            self.hideLoadingIndicator()
            self.dismissKeyboard()
            self.hud.textLabel.text = "リセットメールを送信しました"
            self.hudSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    //MARK: Setup UI
    
    private func setupUI() {
        
        emailTextField.delegate = self
        
        resetButton.layer.cornerRadius = 10
        loginButton.layer.cornerRadius = 10
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballClipRotatePulse, color: UIColor(named: "original yellow"), padding: nil)
    }
    
    //MARK: Helper
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func textFieldHaveText() -> Bool {
        return emailTextField.text != ""
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
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
