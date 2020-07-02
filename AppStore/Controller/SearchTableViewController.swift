//
//  SearchTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/28.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class SearchTableViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var searcnResults: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    //MARK: Search Function
    
    private func searchInFirebase(forName: String) {
        
        searchAlgolia(searchString: forName) { (itemIds) in
            
            downloadItems(itemIds) { (allItems) in
                self.searcnResults = allItems
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func textFieldDidChange(_ textFiled: UITextField) {
        
        if searchTextField.text == "" {
            searcnResults.removeAll()
            tableView.reloadData()
        } else {
            searchInFirebase(forName: searchTextField.text!)
        }
    }
    
    //MARK: IBAction
    @IBAction func dismissKeyboard(_ sender: Any) {
        searchTextField.text = ""
        searchTextField.endEditing(true)
    }
    
    //MARK: Navigation
    
    private func showItemView(_ item: Item) {
        
        let detailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailVC") as! DetailTableViewController
        detailVC.item = item
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    //MARK: Helper Function
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}

//MARK: TableView

extension SearchTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searcnResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        cell.generateCell(searcnResults[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(searcnResults[indexPath.row])
    }
    
}

extension SearchTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label]
        return NSAttributedString(string: "商品は見つかりませんでした。", attributes: attributes)
    }

    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "検索バーより、お求めの商品を検索して下さい。")
    }
}
