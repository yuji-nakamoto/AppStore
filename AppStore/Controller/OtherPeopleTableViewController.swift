//
//  OtherPeopleTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/07/07.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class OtherPeopleTableViewController: UITableViewController {
    
    var userId = ""
    var reviewArray: [Review] = []
    var itemArray: [Item] = []
    var user: User!
    var activityIndicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballClipRotatePulse, color: UIColor(named: "original yellow"), padding: nil)
        loadUser()
    }
    
    //MARL: Load User
    
    private func loadUser() {
        
        downloadUser(userId) { (user) in
            self.user = user
            self.loadReview()
        }
    }
    
    //MARK: Load Review
    
    private func loadReview() {
        
        showLoadingIndicator()
        downloadReview(self.user.reviewId) { (allReview) in
            self.reviewArray = allReview
            self.title = "レビュー数: \(self.reviewArray.count)"
            
            downloadItems(self.user.itemId) { (allItem) in
                self.itemArray = allItem
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.tableView.reloadData()
                self.hideLoadingIndicator()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1 + reviewArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let indexNumber = indexPath.row
        
        if indexNumber == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! OtherPeopleTableViewCell
            
            cell.user = self.user
            return cell
        }
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! ReviewTableViewCell
        
        cell2.generateCell(reviewArray[indexPath.row - 1])
        return cell2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexNumber = indexPath.row
        if indexNumber > 0 {
            
            tableView.deselectRow(at: indexPath, animated: true)
            showItemView(itemArray[indexPath.row - 1])
        }
    }
    
    //MARK: Navigation
    
    private func showItemView(_ item: Item) {
        
        let detailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailVC") as! DetailTableViewController
        detailVC.item = item
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    //MARK: IBAction
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Activity Indicator
    
    private func showLoadingIndicator() {
        
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
    
}
