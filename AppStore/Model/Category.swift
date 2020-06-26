//
//  Category.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/26.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Category {
    
    var id: String
    var name: String
    var image: UIImage?
    var imageName: String?
    
    init(name: String, imageName: String) {
        self.id = ""
        self.name = name
        self.imageName = imageName
        self.image = UIImage(named: imageName)
    }
    
    init(dict: NSDictionary) {
        id = dict[USERID] as! String
        name = dict[NAME] as? String ?? ""
        image = UIImage(named: dict[IMAGENAME] as? String ?? "")
    }
}

//MARK: Download category from firebase

func downloadCategoriesFromFirebase(comletion: @escaping (_ categoryArray: [Category]) -> Void) {
    
    var categoryArray: [Category] = []
    
    firebaseRef(.Category).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            comletion(categoryArray)
            return
        }
        
        if !snapshot.isEmpty {
            for categoryDict in snapshot.documents {
                categoryArray.append(Category(dict: categoryDict.data() as NSDictionary))
            }
        }
        comletion(categoryArray)
    }
}

//MARK: Save category function

func saveCategoryToFirebase(category: Category) {
    
    let id = UUID().uuidString
    category.id = id
    
    firebaseRef(.Category).document(id).setData(categoryDictionaryFrom(category) as! [String : Any])
    
}

//MARK: Helpers

func categoryDictionaryFrom(_ category: Category) -> NSDictionary {
    
    return NSDictionary(objects: [category.id, category.name, category.imageName as Any], forKeys: [USERID as NSCopying, NAME as NSCopying, IMAGENAME as NSCopying])
}

//user only one time
func createCategorySet() {
    
    let clothing = Category(name: "ファッション", imageName: "cloth")
    let footWear = Category(name: "靴", imageName: "footWear")
    let electronics = Category(name: "家電&パソコン", imageName: "electronics")
    let health = Category(name: "ドラッグストア", imageName: "health")
    let baby = Category(name: "ベビー用品", imageName: "baby")
    let home = Category(name: "ホーム&キッチン", imageName: "home")
    let car = Category(name: "車&バイク", imageName: "car")
    let food = Category(name: "食品&飲料", imageName: "food")
    let hobby = Category(name: "ホビー", imageName: "hobby")
    let pet = Category(name: "ペット用品", imageName: "pet")
    let business = Category(name: "ビジネス", imageName: "business")
    let music = Category(name: "ミュージック", imageName: "music")
    let game = Category(name: "ゲーム", imageName: "game")
    let sport = Category(name: "スポーツ", imageName: "sport")
    
    
    let arrayOfCategories = [clothing, footWear, electronics, health, baby, home, car, food, hobby, pet, business, music, game, sport]
    
    for category in arrayOfCategories {
        print("create category")
        saveCategoryToFirebase(category: category)
    }
}
