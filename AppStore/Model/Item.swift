//
//  Item.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/26.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import UIKit

class Item {
    
    var id: String!
    var categoryId: String!
    var name: String!
    var descriprion: String!
    var price: Int!
    var imageLinks: [String]!
    
    init() {
        
    }
    
    init(dict: NSDictionary) {
        
        id = dict[USERID] as? String
        categoryId = dict[CATEGORYID] as? String
        name = dict[NAME] as? String
        descriprion = dict[DESCRIPTION] as? String
        price = dict[PRICE] as? Int
        imageLinks = dict[IMAGELINKS] as? [String]
    }
}

//MARK: Save items func

func saveItemToFirestore(_ item: Item) {
    
    firebaseRef(.Items).document(item.id).setData(itemDictionaryFrom(item) as! [String: Any])
}

//MARK: Helper functions

func itemDictionaryFrom(_ item: Item) -> NSDictionary {
    return NSDictionary(objects: [item.id ?? "", item.categoryId ?? "", item.name ?? "", item.descriprion ?? "", item.price ?? "", item.imageLinks ?? ""], forKeys: [USERID as NSCopying, CATEGORYID as NSCopying, NAME as NSCopying, DESCRIPTION as NSCopying, PRICE as NSCopying, IMAGELINKS as NSCopying])
}

//MARK: Download Func

func downloadItemsFromFirebase(_ withCategoryId: String, completion: @escaping (_ itemArray: [Item]) -> Void) {
    var itemArray: [Item] = []
    
    firebaseRef(.Items).whereField(CATEGORYID, isEqualTo: withCategoryId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else {
            completion(itemArray)
            return
        }
        if !snapshot.isEmpty {
            
            for itemDict in snapshot.documents {
                itemArray.append(Item(dict: itemDict.data() as NSDictionary))
            }
        }
        completion(itemArray)
    }
}

func downloadItems(_ withIds: [String], completion: @escaping (_ itemArray: [Item]) -> Void) {
    
    var count = 0
    var itemArray: [Item] = []
    
    if withIds.count > 0 {
        
        for itemId in withIds {
            
            firebaseRef(.Items).document(itemId).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else {
                    completion(itemArray)
                    return
                }
                if snapshot.exists {
                    
                    itemArray.append(Item(dict: snapshot.data()! as NSDictionary))
                    count += 1
                } else {
                    completion(itemArray)
                }
                if count == withIds.count {
                    
                    completion(itemArray)
                }
            }
        }
    } else {
        completion(itemArray)
    }
}
