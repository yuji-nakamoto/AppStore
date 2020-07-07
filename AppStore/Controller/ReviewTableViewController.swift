//
//  ReviewTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/07/07.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class ReviewTableViewController: UITableViewController {
    
    var reviewArray: [Review] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        loadReview()
    }
    
    //MARK: Load Review
    
    private func loadReview() {
        
        downloadReview(User.currentUser()!.reviewId) { (allReview) in
            self.reviewArray = allReview
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: IBAction
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reviewArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ReviewTableViewCell
        
        cell.generateCell(reviewArray[indexPath.row])

        return cell
    }

}

extension ReviewTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label]
        return NSAttributedString(string: "レビューはありません", attributes: attributes)
    }

    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        return NSAttributedString(string: "商品詳細画面の右上ボタンからレビューが行えます。")
    }
}
