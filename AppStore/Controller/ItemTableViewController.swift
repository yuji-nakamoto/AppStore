//
//  ItemTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/26.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class ItemTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var sellView: UIView!
    
    var categoryArray: [Category] = []
    var category: Category?
    var itemArray: [Item] = []
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        collectionDelegete()
        loadCategory()
        loadItems()
        setupUI()
    }
    
    //MARK: Setup UI
    
    private func setupUI() {
        
        tableView.tableFooterView = UIView()
        sellLabel.text = "\(category!.name) カテゴリーに出品する"
        sellButton.layer.cornerRadius = 5
        self.title = category?.name
        
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
    }
    
    
    //MARK: IBAction
    
    @IBAction func displaySellButtonPressed(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5) {
            self.sellView.isHidden = !self.sellView.isHidden
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Download Category
    private func loadCategory() {
        
        downloadCategoriesFromFirebase { (allCategories) in
            self.categoryArray = allCategories
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: Load Items
    
    private func loadItems() {
        
        downloadItemsFromFirebase(category!.id) { (allItems) in
            self.itemArray = allItems
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: Delegete
    
    private func collectionDelegete() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    //MARK: Prepare Function
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailVC" {

            let detailVC = segue.destination as! DetailTableViewController
            detailVC.item = sender as? Item
        }
        if segue.identifier == "addItemVC" {
            let addVC = segue.destination as! AddItemTableViewController
            addVC.category = category!
        }
    }
    
    //MARK: Helper Function
    
    @objc func refreshTableView(){
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
        refresh.endRefreshing()
    }
    
}

//MARK: CollectionView Function

extension ItemTableViewController:  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 130, height: 130)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ItemCollectionViewCell
        
        cell.generateCell(itemArray[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "detailVC", sender: itemArray[indexPath.row])
    }
}

//MARK: TableView Function

extension ItemTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateCell(itemArray[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: "detailVC", sender: itemArray[indexPath.row])
    }
    
}

extension ItemTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label]
        return NSAttributedString(string: "こちらのカテゴリーには商品がありません。", attributes: attributes)
    }

    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "商品が出品されるまで暫くお待ち下さいませ。")
    }
}
