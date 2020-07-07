//
//  DetailTableViewCell.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import JGProgressHUD

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cartButton: UIButton!
    
    var item: Item!
    var detailVC: DetailTableViewController?
    let hud = JGProgressHUD(style: .dark)
    let generator = UINotificationFeedbackGenerator()
    
    func generateCell(_ item: Item) {
        
        cartButton.layer.cornerRadius = 5
        nameLabel.text = item.name
        descriptionLabel.text = item.descriprion
        priceLabel.text = "¥\(String(item.price))"
    }
    
    //MARK: IBAction
    
    @IBAction func cartButtonPressed(_ sender: Any) {
        
        downloadCartFromFirestore(User.currentUserId()) { (cart) in
            
            if cart == nil {
                self.createNewCart()
            } else {
                cart!.itemIds.append(self.item.id)
                self.updateCart(cart: cart!, withValues: [ITEMIDS : cart!.itemIds!])
            }
        }
    }
    
    //MARK: Creat Cart & Update Cart
    
    private func createNewCart() {
        
        let newCart = Cart()
        newCart.ownerId = User.currentUserId()
        newCart.id = UUID().uuidString
        newCart.itemIds = [self.item.id]
        saveCartToFirestore(newCart)
        
        detailVC!.generator.notificationOccurred(.error)
        hud.textLabel.text = "カートに追加しました"
        hudSuccess()
    }
    
    private func updateCart(cart: Cart, withValues: [String: Any]) {
        
        updateCartInFirestore(cart, withValue: withValues) { (error) in
            
            if error != nil {
                
                self.hud.textLabel.text = "Error: \(error!.localizedDescription)"
                self.hudError()
                print("error updating basket", error!.localizedDescription)
            } else {
                self.detailVC!.generator.notificationOccurred(.error)
                self.hud.textLabel.text = "カートに追加しました"
                self.hudSuccess()
            }
        }
    }
    
    //MARK: Helper Function
    
    private func hudError() {
        
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: detailVC!.view)
        hud.dismiss(afterDelay: 2.0)
    }
    
    private func hudSuccess() {
        
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: detailVC!.view)
        hud.dismiss(afterDelay: 2.0)
    }
    
}
