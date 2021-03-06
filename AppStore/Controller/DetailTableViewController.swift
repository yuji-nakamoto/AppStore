//
//  DetailTableViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import JGProgressHUD
import GoogleMobileAds

class DetailTableViewController: UIViewController {
    
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var animationView: UIView!
    
    var item: Item!
    var itemArray: [Item] = []
    var reviewArray: [Review] = []
    var itemImages: [UIImage] = []
    var userId = ""
    let hud = JGProgressHUD(style: .dark)
    var pleaceholderLbl = UILabel()
    var reviewIdArray: [String] = []
    var itemIdArray: [String] = []
    let currentUser = User.currentUser()
    let generator = UINotificationFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        setupKeyboard()
        setupTextView()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        downloadPicture()
        loadReviewFromFirestore()
    }
    
    //MARK: IBAction
    
    @IBAction func reviewButtonPressed(_ sender: Any) {
        
        if textViewHaveText() == true {
            
            saveToFirebaseReview()
            return
        }
        hud.textLabel.text = "文字を入力して下さい"
        hudError()
    }
    
    @IBAction func writeReviewButtonPressed(_ sender: Any) {
        
        self.animationView.isHidden = !self.animationView.isHidden
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Load Review
    
    func loadReviewFromFirestore() {
        
        downloadReviewFromFirebase(item.id) { (allReview) in
            self.reviewArray = allReview
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: Load Picture
    
    private func downloadPicture() {
        
        if item != nil && item.imageUrls != nil {
            downloadImages(imageUrls: item.imageUrls) { (allImages) in
                if allImages.count > 0 {
                    self.itemImages = allImages as! [UIImage]
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: Save Review
    
    private func saveToFirebaseReview() {
        
        reviewIdArray.removeAll()
        itemIdArray.removeAll()
        
        let review = Review()
        review.reviewId = UUID().uuidString; review.reviewString = textView.text
        review.id = currentUser?.objectId; review.itemId = item.id
        review.fullname = currentUser?.fullName; review.profileImageUrl = currentUser?.profileImageUrl
        review.imageUrls = item.imageUrls; review.name = item.name
        reviewIdArray.append(review.reviewId)
        itemIdArray.append(review.itemId)
        saveReviewToFirestore(review)
        
        addIdArray(reviewIdArray, itemIdArray)
        
        item.reviewCount = reviewArray.count + 1
        updateItemFirestore(item)
        
        hud.textLabel.text = "レビューを投稿しました"
        hudSuccess()
        dismissView()
    }
    
    //MARK: Prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "otherVC" {
            
            let otherVC = segue.destination as! OtherPeopleTableViewController
            otherVC.userId = userId
        }
    }
    
    //MARK: Add Id Array
    
    private func addIdArray(_ reviewIds: [String], _ itemIds: [String]) {
        
        if let currentUser = User.currentUser() {
            
            let newReviewIds = currentUser.reviewId + reviewIds
            let newItemIds = currentUser.itemId + itemIds
            updateCurrentUserFirestore(withValues: [REVIEWID : newReviewIds, ITEMIDS: newItemIds]) { (error) in
                
                if error != nil {
                    print("Error adding reviewIds", error!.localizedDescription)
                }
            }
        }
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
        return 1 + 1 + 1 + reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DetailTableViewCell
            
            cell.generateCell(item)
            cell.item = self.item
            cell.detailVC = self
            
            return cell
            
        } else if indexPath.row == 1 {
            
            let bannerCell = tableView.dequeueReusableCell(withIdentifier: "BannerCell", for: indexPath)
            let bannerView = bannerCell.viewWithTag(1) as! GADBannerView
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            
            return bannerCell
            
        } else if indexPath.row == 2 {
            
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! ReviewCountTableViewCell
            
            cell2.reviewCountLabel.text = String(reviewArray.count)
            return cell2
        }
        let cell3 = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as! ReviewTableViewCell
        
        cell3.generateCell(reviewArray[indexPath.row - 3])
        return cell3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row > 2 {
            
            tableView.deselectRow(at: indexPath, animated: true)
            userId = reviewArray[indexPath.row - 3].id
            performSegue(withIdentifier: "otherVC", sender: nil)
        }
    }
}
