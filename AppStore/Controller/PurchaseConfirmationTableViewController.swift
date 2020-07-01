//
//  PurchaseConfirmationTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/30.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import JGProgressHUD

class PurchaseConfirmationTableViewController: UITableViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var apartmentLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    
    var cart: Cart?
    var purchasedItemIds: [String] = []
    var allItems: [Item] = []
    let currentUser = User.currentUser()
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUserInfo()
        loadCartFromFirestore()
    }
    
    //MARK: Setup UI
    
    private func setupUI() {
        usernameLabel.text = ""
        addressLabel.text = ""
        apartmentLabel.text = ""
        
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.systemGray4.cgColor
        confirmButton.layer.cornerRadius = 5
        tableView.tableFooterView = UIView()
    }
    
    //MARK: Load User Info
    
    private func loadUserInfo() {
        
        if currentUser?.fullName != "" {
            usernameLabel.text = currentUser?.fullName
            topLabel.isHidden = false
            confirmButton.isEnabled = true
            
        } else {
            addressLabel.text = "購入するには住所を登録して下さい"
            topLabel.isHidden = true
            confirmButton.isEnabled = false
            confirmButton.alpha = 0.5
        }
        
        if currentUser?.fullAddress != "" {
            addressLabel.text = currentUser?.fullAddress
        }
        
        if currentUser?.apartment != "" {
            apartmentLabel.text = currentUser?.apartment
        }
    }
    
    //MARK: Load Cart & Items
    
    private func loadCartFromFirestore() {
        
        downloadCartFromFirestore(User.currentUserId()) { (cart) in
            self.cart = cart
            self.getCarItems()
        }
    }
    
    private func getCarItems() {
        
        if cart != nil {
            downloadItems(cart!.itemIds) { (Items) in
                self.allItems = Items
            }
        }
    }
    
    //MARK: IBAction
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        tempFunction()
        addItemsToPurchaseHistory(self.purchasedItemIds)
        emptyTheBasket()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func toEditVCButtonPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editVC = storyboard.instantiateViewController(withIdentifier: "EditVC")
        self.present(editVC, animated: true, completion: nil)
    }
    
    //MARK: Helper Function
    
    private func tempFunction() {
        
        for item in allItems {
            purchasedItemIds.append(item.id)
        }
    }
    
    private func addItemsToPurchaseHistory(_ itemIds: [String]) {
        
        if User.currentUser() != nil {
            
            let newItemIds = User.currentUser()!.purchasedItemId + itemIds
            updateCurrentUserFierstore(withValues: [PURCHAESDITEMID : newItemIds]) { (error) in
                
                if error != nil {
                    print("Error adding purchased items", error!.localizedDescription)
                }
                self.hud.textLabel.text = "購入が完了しました"
                self.hudSuccess()
            }
        }
    }
    
    private func emptyTheBasket() {
        
        purchasedItemIds.removeAll()
        allItems.removeAll()
        
        cart!.itemIds = []
        
        updateCartInFirestore(cart!, withValue: [ITEMIDS: cart!.itemIds!]) { (error) in
            
            if error != nil {
                print("Error updating basket", error!.localizedDescription)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func hudSuccess() {
        
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0)
    }
    
}
