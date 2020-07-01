//
//  Review.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/30.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation

class Review {
    
    var id: String!
    var reviewId: String!
    var reviewString: String!
    var itemId: String!
    var fullname: String!
    var profileImageUrl: String!
    
    init() {
        
    }
    
    init(dict: NSDictionary) {
        
        id = dict[OBJECTID] as? String ?? ""
        reviewId = dict[REVIEWID] as? String ?? ""
        reviewString = dict[REVIEWSTRING] as? String ?? ""
        itemId = dict[ITEMIDS] as? String ?? ""
        fullname = dict[FULLNAME] as? String ?? ""
        profileImageUrl = dict[PROFILEIMAGEURL] as? String ?? ""
    }
}

//MARK: Helper Function

func reviewDictionaryFrom(_ review: Review) -> NSDictionary {
    return NSDictionary(objects: [review.id ?? "", review.reviewId ?? "", review.reviewString ?? "", review.itemId ?? "", review.fullname ?? "", review.profileImageUrl ?? ""], forKeys: [OBJECTID as NSCopying, REVIEWID as NSCopying, REVIEWSTRING as NSCopying, ITEMIDS as NSCopying, FULLNAME as NSCopying, PROFILEIMAGEURL as NSCopying])
}

//MARK: Save Review to Firebase

func saveReviewToFirestore(_ review: Review) {
    
    firebaseRef(.Review).document(review.reviewId).setData(reviewDictionaryFrom(review) as! [String: Any]) { (error) in
        
        if error != nil {
            print("error saving review: \(error!.localizedDescription)")
        }
    }
}

//MARK: Download Func

func downloadReviewFromFirebase(_ withItemId: String, completion: @escaping (_ reviewArray: [Review]) -> Void) {
    var reviewArray: [Review] = []
    
    firebaseRef(.Review).whereField(ITEMIDS, isEqualTo: withItemId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else {
            completion(reviewArray)
            return
        }
        if !snapshot.isEmpty {
            
            for reviewDict in snapshot.documents {
                reviewArray.append(Review(dict: reviewDict.data() as NSDictionary))
            }
        }
        completion(reviewArray)
    }
}
