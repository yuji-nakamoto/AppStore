//
//  AddItemViewController.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Gallery
import JGProgressHUD
import NVActivityIndicatorView

class AddItemViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var textViewBorder: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var anyLabel: UILabel!
    @IBOutlet weak var ImageSelectButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    
    var hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView!
    var gallery: GalleryController!
    var pleaceholderLbl = UILabel()
    var itemImages: [UIImage?] = []
    var category: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTextView()
    }
    
    private func setupUI() {
        
        self.title = "商品の情報を入力"
        textViewBorder.layer.borderWidth = 1
        textViewBorder.layer.borderColor = UIColor.systemGray4.cgColor
        textViewBorder.layer.cornerRadius = 5
        anyLabel.layer.borderWidth = 1
        anyLabel.layer.borderColor = UIColor.systemGray.cgColor
        ImageSelectButton.layer.cornerRadius = 10
        sellButton.layer.cornerRadius = 10
        
        nameTextField.delegate = self
        priceTextField.delegate = self
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballClipRotatePulse, color: UIColor(named: "original yellow"), padding: nil)
    }
    
    //MARK: IBAction
    
    @IBAction func imageSelectButtonPressed(_ sender: Any) {
        
        itemImages = []
        showImageGallery()
    }
    
    @IBAction func sellButtonPressed(_ sender: Any) {
        
        if textFieldHaveText() == true {
            
            saveToFirebase()
        } else {
            hud.textLabel.text = "必須項目を全て入力して下さい"
            hudError()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    //MARK: Save Item
    
    private func saveToFirebase() {
        
        showLoadingIndicator()
        
        let item = Item()
        item.id = UUID().uuidString
        item.name = nameTextField.text!
        item.categoryId = category.id
        item.descriprion = textView.text!
        item.price = Int(priceTextField.text!)
        
        if itemImages.count > 0 {
            
            uploadImages(images: itemImages, itemId: item.id) { (imageLinkArray) in
                
                item.imageLinks = imageLinkArray
                
                saveItemToFirestore(item)
                saveItemToAlgolia(item: item)
                
                self.hideLoadingIndicator()
                self.hud.textLabel.text = "商品を出品しました"
                self.hudSuccess()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.popTheView()
                }
            }
        } else {
            saveItemToFirestore(item)
            saveItemToAlgolia(item: item)
            self.hideLoadingIndicator()
            popTheView()
        }
    }
    
    //MARK: Show Gallery
    private func showImageGallery() {
        
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 6
        
        self.present(self.gallery, animated: true, completion: nil)
    }
    
    
    //MARK: Helper Function
    
    private func setupTextView() {
        textView.delegate = self
        pleaceholderLbl.isHidden = false
        
        let pleaceholderX: CGFloat = self.view.frame.size.width / 75
        let pleaceholderY: CGFloat = -40
        let pleaceholderWidth: CGFloat = textView.bounds.width - pleaceholderX
        let pleaceholderHeight: CGFloat = textView.bounds.height
        let pleaceholderFontSize = self.view.frame.size.width / 25
        
        pleaceholderLbl.frame = CGRect(x: pleaceholderX, y: pleaceholderY, width: pleaceholderWidth, height: pleaceholderHeight)
        pleaceholderLbl.text = "商品の特徴や機能、仕様、魅力など"
        pleaceholderLbl.font = UIFont(name: "HelveticaNeue", size: pleaceholderFontSize)
        pleaceholderLbl.textColor = .systemGray3
        pleaceholderLbl.textAlignment = .left
        
        textView.addSubview(pleaceholderLbl)
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func popTheView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func textFieldHaveText() -> Bool {
        
        return (nameTextField.text != "" && priceTextField.text != "" && textView.text != "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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

extension AddItemViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let spacing = CharacterSet.whitespacesAndNewlines
        
        if !textView.text.trimmingCharacters(in: spacing).isEmpty {
            
            pleaceholderLbl.isHidden = true
        } else {
            pleaceholderLbl.isHidden = false
        }
    }
}

extension AddItemViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            
            Image.resolve(images: images) { (resolvedImage) in
                self.itemImages = resolvedImage
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}



