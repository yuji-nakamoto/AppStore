//
//  Cart.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/28.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation

class Cart {
    
    var id: String!
    var ownerId: String!
    var itemIds: [String]!
    
    init() {
    }
    
    init(dict: NSDictionary) {
        id = dict[OBJECTID] as? String
        ownerId = dict[OWNERID] as? String
        itemIds = dict[ITEMIDS] as? [String]
    }
}

//MARK: Download items
func downloadCartFromFirestore(_ ownerId: String, completion: @escaping (_ cart: Cart?) -> Void) {
    
    firebaseRef(.Cart).whereField(OWNERID, isEqualTo: ownerId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completion(nil)
            return
        }
        
        if !snapshot.isEmpty && snapshot.documents.count > 0 {
            let cart = Cart(dict: snapshot.documents.first!.data() as NSDictionary)
            completion(cart)
        } else {
            completion(nil)
        }
    }
}

//MARK: Save to Firebase
func saveCartToFirestore(_ cart: Cart) {
    
    firebaseRef(.Cart).document(cart.id).setData(cartDictionaryFrom(cart) as! [String: Any])
}

//MARK: Helper functions

func cartDictionaryFrom(_ cart: Cart) -> NSDictionary {
    return NSDictionary(objects: [cart.id ?? "", cart.ownerId ?? "", cart.itemIds ?? ""], forKeys: [OBJECTID as NSCopying, OWNERID as NSCopying, ITEMIDS as NSCopying])
}

//MARK: Update basket
func updateCartInFirestore(_ cart: Cart, withValue: [String: Any], completion: @escaping (_ error: Error?) -> Void) {
    
    firebaseRef(.Cart).document(cart.id).updateData(withValue) { (error) in
        completion(error)
    }
}
