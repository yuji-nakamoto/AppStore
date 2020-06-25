//
//  User.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/25.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import FirebaseAuth

class User {
    
    var userId: String
    var email: String
    var firstName: String
    var lastName: String
    var address: String
    var purchasedItemId: [String]
    var fullName: String
    
    init(userId: String, email: String, firstName: String, lastName: String) {
        self.userId = userId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = firstName + lastName
        self.address = ""
        self.purchasedItemId = []
    }
    
    init(dict: NSDictionary) {
        userId = dict[USERID] as? String ?? ""
        email = dict[EMAIL] as? String ?? ""
        firstName = dict[FIRSTNAME] as? String ?? ""
        lastName = dict[LASTNAME] as? String ?? ""
        fullName = firstName + lastName
        address = dict[ADDRESS] as? String ?? ""
        purchasedItemId = dict[PURCHAESDITEMID] as? [String] ?? []
        
    }
    
    class func currentUserId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    //MARK: Login function
    
    class func loginUser(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            
            if error == nil {
                downloadUserFromFirestore(userId: authResult!.user.uid, email: email)
                completion(error)
            } else {
                print("error login user: \(error!.localizedDescription)")
                completion(error)
            }
        }
    }
    
    class func createUser(email: String, password: String, completion: @escaping(_ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
            if error != nil {
                print("error create user: \(error!.localizedDescription)")
            }
            completion(error)
        }
    }
    
    class func resetPassword(email: String, completion: @escaping(_ error: Error?) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            
            if error != nil {
                print("error reset password: \(error!.localizedDescription)")
            }
            completion(error)
        }
    }
}




//MARL: Helper Function

func userDictionaryFrom(user: User) -> NSDictionary {
    
    return NSDictionary(objects: [user.userId, user.email, user.firstName, user.lastName, user.fullName, user.address, user.purchasedItemId], forKeys: [USERID as NSCopying, EMAIL as NSCopying, FIRSTNAME as NSCopying, LASTNAME as NSCopying, FULLNAME as NSCopying, ADDRESS as NSCopying, PURCHAESDITEMID as NSCopying])
}

//MARK: Download User

func downloadUserFromFirestore(userId: String, email: String) {
    
    firebaseRef(.User).document(userId).getDocument { (snapshot, error) in
        
        if error != nil {
            
            print("error: download user: \(error!.localizedDescription)")
            return
        }
        let user = User(userId: userId, email: email, firstName: "", lastName: "")
        saveUserToFirestore(user: user)
    }
}

//MARK: Save user to firebase
func saveUserToFirestore(user: User) {
    
    firebaseRef(.User).document(user.userId).setData(userDictionaryFrom(user: user) as! [String: Any]) { (error) in
        
        if error != nil {
            print("error saving user: \(error!.localizedDescription)")
        }
    }
}
