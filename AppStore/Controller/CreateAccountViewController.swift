//
//  CreateAccountViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/25.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK IBAction
    
    @IBAction func accountButtonPressed(_ sender: Any) {
        
        if textFieldHaveText() == true {
            
            createUser()
        } else {
            hud.textLabel.text = "入力欄を全て埋めてください"
            hudError()
        }
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Create user
    
    private func createUser() {
        
        showLoadingIndicator()
        
        User.createUser(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error != nil {
                self.hud.textLabel.text = error!.localizedDescription
                self.hudError()
                self.hideLoadingIndicator()
                return
            }
            User.loginUser(email: self.emailTextField.text!, password: self.passwordTextField.text!) { (error) in
                
                self.hideLoadingIndicator()
                self.dismissKeyboard()
                self.hud.textLabel.text = "アカウントの作成に成功しました"
                self.hudSuccess()
                self.toTabbarVC()
            }
        }
    }

    
    //MARK: Setup UI
    
    private func setupUI() {
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        createAccountButton.layer.cornerRadius = 10
        loginButton.layer.cornerRadius = 10
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 110, width: 60.0, height: 60.0), type: .ballClipRotatePulse, color: UIColor(named: "original yellow"), padding: nil)
    }
    
    //MARK: Helper
    
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
