//
//  CartTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/28.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class CartTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cashRegisterButton: UIButton!
    
    var items: [Item] = []
    var cart: Cart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupUI()
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
                self.items = Items
                self.tableView.reloadData()
                self.setupUI()
            }
        } else {
            self.tableView.reloadData()
            self.setupUI()
        }
    }
    
    //MARK: Setup UI
    
    private func setupUI() {
        
        cashRegisterButton.layer.cornerRadius = 5
        
        if items.count == 0 {
            cashRegisterButton.isHidden = true
        } else {
            cashRegisterButton.isHidden = false
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
        return items.count == 0 ? 0 : 1 + items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let indexNumber = indexPath.row
        var totalPrice = 0
        
        if indexNumber == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TotalPriceTableViewCell
            
            for item in items {
                totalPrice += item.price
            }
            cell.totalLabel.text = "(\(String(items.count))個の商品)(税込):"
            cell.totalPriceLabel.text = "¥\(String(totalPrice))"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! CartTableViewCell
        
        cell.generateCell(items[indexPath.row - 1])
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
        showItemView(items[indexPath.row - 1])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let itemDelete = items[indexPath.row - 1]
            
            items.remove(at: indexPath.row - 1)
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

extension CartTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label]
        return NSAttributedString(string: "お客様のショッピングカートに商品はありません。", attributes: attributes)
    }

    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "商品カテゴリー、または検索から買い物が行えます。")
    }
}
