//
//  Item.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/26.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchClient

class Item {
    
    var id: String!
    var categoryId: String!
    var name: String!
    var descriprion: String!
    var price: Int!
    var imageUrls: [String]!
    
    init() {
        
    }
    
    init(dict: NSDictionary) {
        
        id = dict[OBJECTID] as? String
        categoryId = dict[CATEGORYID] as? String
        name = dict[NAME] as? String
        descriprion = dict[DESCRIPTION] as? String
        price = dict[PRICE] as? Int
        imageUrls = dict[IMAGEURLS] as? [String]
    }
}

//MARK: Save items func

func saveItemToFirestore(_ item: Item) {
    
    firebaseRef(.Items).document(item.id).setData(itemDictionaryFrom(item) as! [String: Any])
}

//MARK: Helper functions

func itemDictionaryFrom(_ item: Item) -> NSDictionary {
    return NSDictionary(objects: [item.id ?? "", item.categoryId ?? "", item.name ?? "", item.descriprion ?? "", item.price ?? "", item.imageUrls ?? ""], forKeys: [OBJECTID as NSCopying, CATEGORYID as NSCopying, NAME as NSCopying, DESCRIPTION as NSCopying, PRICE as NSCopying, IMAGEURLS as NSCopying])
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

//MARK: Algolia Function

func saveItemToAlgolia(item: Item) {
    
    let index = AlgoliaService.shared.index
    let itemToSave = itemDictionaryFrom(item) as! [String: Any]
    
    index.addObject(itemToSave, withID: item.id, requestOptions: nil) { (content, error) in
        
        if error != nil {
            print("error saving to algolia", error!.localizedDescription)
        } else {
            print("added to algolia")
        }
    }
}

func searchAlgolia(searchString: String, completion: @escaping (_ itemArray: [String]) -> Void) {
    
    let index = AlgoliaService.shared.index
    var resultIds: [String] = []
    
    let query = Query(query: searchString)
    
    query.attributesToRetrieve = ["name", "description"]
    
    index.search(query) { (content, error) in
        
        if error == nil {
            let cont = content!["hits"] as! [[String: Any]]
            
            resultIds = []
            
            for result in cont {
                resultIds.append(result["objectID"] as! String)
            }
            
            completion(resultIds)
        } else {
            print("Error algolia search", error!.localizedDescription)
            completion(resultIds)
        }
    }
}
