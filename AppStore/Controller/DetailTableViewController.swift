//
//  DetailTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import JGProgressHUD

class DetailTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cartButton: UIButton!
    
    var item: Item!
    var itemArray: [Item] = []
    var itemImages: [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "商品の詳細"
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.tableFooterView = UIView()
        cartButton.layer.cornerRadius = 10
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        downloadPicture()
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Load Picture
    private func downloadPicture() {
        
        if item != nil && item.imageUrls != nil {
            downloadImages(imageUrls: item.imageUrls) { (allImages) in
                if allImages.count > 0 {
                    self.itemImages = allImages as! [UIImage]
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: Add to basket
    
    private func createNewCart() {
        
        let newCart = Cart()
        
        newCart.ownerId = User.currentUserId()
        newCart.id = UUID().uuidString
        newCart.itemIds = [self.item.id]
        saveCartToFirestore(newCart)
        
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
                self.hud.textLabel.text = "カートに追加しました"
                self.hudSuccess()
            }
        }
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
    
}

//MARK: CollectionView Function

extension DetailTableViewController:  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 250, height: 250)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImages.count == 0 ? 1 : itemImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DetailCollectionViewCell
        
        if itemImages.count > 0 {
            cell.setupImageWith(itemImage: itemImages[indexPath.row])
        }
        return cell
    }
    
}

//MARK: TableView Function

extension DetailTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DetailTableViewCell
        
        cell.nameLabel.text = item.name
        cell.priceLabel.text = "¥\(String(item.price))"
        cell.descriptionLabel.text = item.descriprion
        
        return cell
    }
    
}
