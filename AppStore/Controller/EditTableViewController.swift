//
//  EditTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/28.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import JGProgressHUD

class EditTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextFiled: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var prefecturesTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var apartmentTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    
    
    var hud = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerButton.layer.cornerRadius = 10
        tableView.tableFooterView = UIView()
        textFieldDelegate()
        loadUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        registerButtonChange()
    }
    
    //MARK: IBAction
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func registerButonPressed(_ sender: Any) {
        
        if textFieldHaveText() == true {
            
            let withValues = [FIRSTNAME: firstNameTextFiled.text!, LASTNAME: lastNameTextField.text!, FULLNAME: (firstNameTextFiled.text! + " " + lastNameTextField.text!), PREFECTURES: prefecturesTextField.text!, CITY: cityTextField.text!, APARTMENT: apartmentTextField.text!, FULLADDRESS: (prefecturesTextField.text! + cityTextField.text! + apartmentTextField.text!)]
            
            updateCurrentUserFierstore(withValues: withValues) { (error) in
                
                if error == nil {
                    
                    self.hud.textLabel.text = "住所を登録しました"
                    self.hudSuccess()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("error updating user", error!.localizedDescription)
                    self.hudError()
                }
            }
            
        } else {
            self.hud.textLabel.text = "必須項目を入力して下さい"
            self.hudError()
        }
    }
    
    private func loadUserInfo() {
        
        if User.currentUser() != nil {
            
            let currentUser = User.currentUser()!
            firstNameTextFiled.text = currentUser.firstName
            lastNameTextField.text = currentUser.lastName
            prefecturesTextField.text = currentUser.prefectures
            cityTextField.text = currentUser.city
            apartmentTextField.text = currentUser.apartment
        }
    }
    
    //MARK: Helper Function
    
    private func registerButtonChange() {
        
        if textFieldHaveText() == true {
            
            registerButton.titleLabel?.text = "住所を変更"
            topLabel.text = "住所を変更する"
        }
    }
    
    private func textFieldHaveText() -> Bool {
        
        return (firstNameTextFiled.text != "" && lastNameTextField.text != "" && prefecturesTextField.text != "" && cityTextField.text != "")
    }
    
    private func textFieldDelegate() {
        
        firstNameTextFiled.delegate = self
        lastNameTextField.delegate = self
        prefecturesTextField.delegate = self
        cityTextField.delegate = self
        apartmentTextField.delegate = self
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
    
}
