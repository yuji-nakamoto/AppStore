//
//  LoginViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/25.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var kantanButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    var hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if textFieldHaveText() == true {
            
            loginUser()
        } else {
            hud.textLabel.text = "メールアドレスとパスワードを入力してください"
            hudError()
        }
    }
    
    @IBAction func kantanButtonPressed(_ sender: Any) {
        hud.textLabel.text = "簡単ログインしました"
        hudSuccess()
        toTabbarVC()
    }
    
    //MARK: Login user
    
    private func loginUser() {
        
        showLoadingIndicator()
        User.loginUser(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error != nil {
                self.hud.textLabel.text = error!.localizedDescription
                self.hudError()
                self.hideLoadingIndicator()
                return
            }
            self.hideLoadingIndicator()
            self.hud.textLabel.text = "ログインに成功しました"
            self.hudSuccess()
            self.toTabbarVC()
        }
    }
    
    //MARK: Setup UI
    
    private func setupUI() {
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.layer.cornerRadius = 10
        createAccountButton.layer.cornerRadius = 10
        kantanButton.layer.cornerRadius = 10
        kantanButton.layer.borderWidth = 1
        kantanButton.layer.borderColor = UIColor(named: "original yellow")?.cgColor
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballClipRotatePulse, color: UIColor(named: "original yellow"), padding: nil)
    }
    
    //MARK: Heleper
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func textFieldHaveText() -> Bool {
        
        return (emailTextField.text != "" && passwordTextField.text != "")
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
    
    //MARK: Storyboard segue
    
    private func toTabbarVC() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabbarVC")
            self.present(tabBarVC, animated: true, completion: nil)
        }
    }
    

}
