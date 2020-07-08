//
//  PurchasedTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/30.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class PurchasedTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var itemArray: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        self.title = "注文履歴"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadItems()
    }
    
    //MARK: Load Items

    private func loadItems() {
        
        downloadItems(User.currentUser()!.purchasedItemId) { (allItems) in
            self.itemArray = allItems
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Navigation
    
    private func showItemView(_ item: Item) {
        
        let detailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailVC") as! DetailTableViewController
        detailVC.item = item
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

extension PurchasedTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PurchasedTableViewCell
        
        cell.generateCell(itemArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(itemArray[indexPath.row])
    }
}

extension PurchasedTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label]
        return NSAttributedString(string: "購入した商品はありません。", attributes: attributes)
    }

    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "商品カテゴリー、または検索から買い物が行えます。")
    }
}
