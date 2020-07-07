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
    
    //MARK: Setup UI
    
    private func setupUI() {
        
        self.title = "商品の詳細"
        tableView.tableFooterView = UIView()
        reviewButton.layer.cornerRadius = 5
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.systemGray4.cgColor
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
    
    private func loadReviewFromFirestore() {
        
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
        
        let review = Review()
        review.reviewId = UUID().uuidString
        review.reviewString = textView.text
        review.id = currentUser?.objectId
        review.itemId = item.id
        review.fullname = currentUser?.fullName
        review.profileImageUrl = currentUser?.profileImageUrl
        reviewIdArray.append(review.reviewId)
        saveReviewToFirestore(review)
        
        addReviewIdArray(reviewIdArray)
        
        item.reviewCount = reviewArray.count + 1
        updateItemFirestore(item)
        
        hud.textLabel.text = "レビューを投稿しました"
        hudSuccess()
        dismissView()
    }
    
    //MARK: Helper Function
    
    private func addReviewIdArray(_ reviewIds: [String]) {
        
        if let currentUser = User.currentUser() {
            
            let newReviewIds = currentUser.reviewId + reviewIds
            updateCurrentUserFirestore(withValues: [REVIEWID : newReviewIds]) { (error) in
                
                if error != nil {
                    print("Error adding reviewIds", error!.localizedDescription)
                }
            }
        }
    }
    
    //MARK: Prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "otherVC" {
            
            let otherVC = segue.destination as! OtherPeopleTableViewController
            otherVC.userId = userId
        }
    }
    
    private func dismissView() {
        
        textView.resignFirstResponder()
        textView.text = ""
        self.animationView.isHidden = !self.animationView.isHidden
        loadReviewFromFirestore()
        scrollToBottom()
    }
    
    func scrollToBottom() {
        
        let index = IndexPath(row: reviewArray.count, section: 0)
        tableView.scrollToRow(at: index, at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
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
    
    private func textViewHaveText() -> Bool {
        return textView.text != ""
    }
    
    private func setupTextView() {
        
        textView.delegate = self
        pleaceholderLbl.isHidden = false
        
        let pleaceholderX: CGFloat = self.view.frame.size.width / 75
        let pleaceholderY: CGFloat = -50
        let pleaceholderWidth: CGFloat = textView.bounds.width - pleaceholderX
        let pleaceholderHeight: CGFloat = textView.bounds.height
        let pleaceholderFontSize = self.view.frame.size.width / 25
        
        pleaceholderLbl.frame = CGRect(x: pleaceholderX, y: pleaceholderY, width: pleaceholderWidth, height: pleaceholderHeight)
        pleaceholderLbl.text = "気に入ったことや、気に入らなかったこと"
        pleaceholderLbl.font = UIFont(name: "HelveticaNeue", size: pleaceholderFontSize)
        pleaceholderLbl.textColor = .systemGray4
        pleaceholderLbl.textAlignment = .left
        
        textView.addSubview(pleaceholderLbl)
    }
    
    func setupKeyboard() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            bottomConstraint.constant = 0
        } else {
            if #available(iOS 11.0, *) {
                bottomConstraint.constant = view.safeAreaInsets.bottom - keyboardViewEndFrame.height
            } else {
                bottomConstraint.constant = keyboardViewEndFrame.height
            }
            view.layoutIfNeeded()
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
        return 1 + 1 + reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let indexNumber = indexPath.row
        
        if indexNumber == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DetailTableViewCell
            
            cell.generateCell(item)
            cell.item = self.item
            cell.detailVC = self
            
            return cell
            
        } else if indexNumber == 1 {
            
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! ReviewCountTableViewCell
            
            cell2.reviewCountLabel.text = String(reviewArray.count)
            return cell2
            
        }
        let cell3 = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as! ReviewTableViewCell
        
        cell3.generateCell(reviewArray[indexPath.row - 2])
        return cell3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexNumber = indexPath.row
        if indexNumber > 1 {
            
            userId = reviewArray[indexPath.row - 2].id
            performSegue(withIdentifier: "otherVC", sender: nil)
        }
    }
}

extension DetailTableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let spacing = CharacterSet.whitespacesAndNewlines
        
        if !textView.text.trimmingCharacters(in: spacing).isEmpty {
            
            pleaceholderLbl.isHidden = true
        } else {
            pleaceholderLbl.isHidden = false
        }
    }
}
