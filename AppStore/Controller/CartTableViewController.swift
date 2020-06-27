//
//  CartTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/28.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class CartTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cashRegisterButton: UIButton!
    
    var Items: [Item] = []
    var cart: Cart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        cashRegisterButton.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadCartFromFirestore()
    }
    
    //MARK: Load Cart Items
    
    private func loadCartFromFirestore() {
        
        downloadCartFromFirestore(User.currentUserId()) { (cart) in
            
            self.cart = cart
            self.getCarItems()
        }
    }
    
    private func getCarItems() {
        
        if cart != nil {
            downloadItems(cart!.itemIds) { (Items) in
                self.Items = Items
                self.tableView.reloadData()
            }
        } else {
            self.tableView.reloadData()
        }
    }
    
    //MARK: Navigation
    
    private func showItemView(_ item: Item) {
        
        let detailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailVC") as! DetailTableViewController
        detailVC.item = item
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    //MARK: Remove Function
    
    private func removeItemFromCart(itemId: String) {
        
        for i in 0..<cart!.itemIds.count {
            
            if itemId == cart!.itemIds[i] {
                cart!.itemIds.remove(at: i)
                
                return
            }
        }
    }
    
}

//MARK: TableView Function

extension CartTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + Items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let indexNumber = indexPath.row
        var totalPrice = 0
        
        if indexNumber == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TotalPriceTableViewCell
            
            for item in Items {
                totalPrice += item.price
            }
            cell.totalLabel.text = "(\(String(Items.count))個の商品)(税込):"
            cell.totalPriceLabel.text = "¥\(String(totalPrice))"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! CartTableViewCell
        
        cell.generateCell(Items[indexPath.row - 1])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let indexNumber = indexPath.row
        if indexNumber == 0 {
            return 61
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(Items[indexPath.row - 1])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let itemDelete = Items[indexPath.row]
            
            Items.remove(at: indexPath.row)
            tableView.reloadData()
            
            removeItemFromCart(itemId: itemDelete.id)
            
            updateCartInFirestore(cart!, withValue: [ITEMIDS : cart!.itemIds!]) { (error) in
                
                if error != nil {
                    print("error updating the basket", error!.localizedDescription)
                }
                
                self.getCarItems()
            }
        }
    }
    
}
