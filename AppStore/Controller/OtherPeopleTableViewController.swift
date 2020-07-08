//
//  OtherPeopleTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/07/07.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class OtherPeopleTableViewController: UITableViewController {
    
    var userId = ""
    var reviewArray: [Review] = []
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
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
        
        downloadReview(self.user.reviewId) { (allReview) in
            self.reviewArray = allReview
            self.title = "レビュー数 \(self.reviewArray.count)"
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1 + reviewArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! OtherPeopleTableViewCell
            
            cell.user = self.user
            return cell
        }
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! ReviewTableViewCell
        
        cell2.generateCell(reviewArray[indexPath.row - 1])
        return cell2
    }
    
    //MARK: IBAction
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
