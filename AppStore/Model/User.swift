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
    var profileImageUrl: String
    var headerImageUrl: String
    var prefectures: String
    var city: String
    var apartment: String
    var fullAddress: String
    var purchasedItemId: [String]
    var fullName: String
    
    init(userId: String, email: String, firstName: String, lastName: String) {
        self.userId = userId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = firstName + lastName
        self.profileImageUrl = ""
        self.headerImageUrl = ""
        self.prefectures = ""
        self.city = ""
        self.apartment = ""
        self.fullAddress = ""
        self.purchasedItemId = []
    }
    
    init(dict: NSDictionary) {
        userId = dict[USERID] as? String ?? ""
        email = dict[EMAIL] as? String ?? ""
        firstName = dict[FIRSTNAME] as? String ?? ""
        lastName = dict[LASTNAME] as? String ?? ""
        fullName = firstName + lastName
        profileImageUrl = dict[PROFILEIMAGEURL] as? String ?? ""
        headerImageUrl = dict[HEADERIMAGEURL] as? String ?? ""
        prefectures = dict[PREFECTURES] as? String ?? ""
        city = dict[CITY] as? String ?? ""
        apartment = dict[APARTMENT] as? String ?? ""
        fullAddress = prefectures + city + apartment
        purchasedItemId = dict[PURCHAESDITEMID] as? [String] ?? []
        
    }
    
    //MARK: Return User
    
    class func currentUserId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> User? {
        
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: CURRENTUSER) {
                return User.init(dict: dictionary as! NSDictionary)
            }
        }
        return nil
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
    
    class func createUser(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
            if error != nil {
                print("error create user: \(error!.localizedDescription)")
            }
            completion(error)
        }
    }
    
    class func logoutUser(completion: @escaping (_ error: Error?) -> Void) {
        
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: CURRENTUSER)
            UserDefaults.standard.synchronize()
            completion(nil)
            
        } catch let error as NSError {
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
    
    return NSDictionary(objects: [user.userId, user.email, user.firstName, user.lastName, user.fullName, user.profileImageUrl, user.headerImageUrl, user.prefectures, user.city, user.apartment, user.fullAddress, user.purchasedItemId], forKeys: [USERID as NSCopying, EMAIL as NSCopying, FIRSTNAME as NSCopying, LASTNAME as NSCopying, FULLNAME as NSCopying, PROFILEIMAGEURL as NSCopying, HEADERIMAGEURL as NSCopying, PREFECTURES as NSCopying, CITY  as NSCopying, APARTMENT as NSCopying, FULLADDRESS as NSCopying, PURCHAESDITEMID as NSCopying])
}

//MARK: Download User

func downloadUserFromFirestore(userId: String, email: String) {
    
    firebaseRef(.User).document(userId).getDocument { (snapshot, error) in
        
        guard let snapshot = snapshot else {
            return
        }
        if snapshot.exists {
            
            saveUserLocally(userDict: snapshot.data()! as NSDictionary)
        } else {
            let user = User(userId: userId, email: email, firstName: "", lastName: "")
            saveUserLocally(userDict: userDictionaryFrom(user: user))
            saveUserToFirestore(user: user)
        }
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

func saveUserLocally(userDict: NSDictionary) {
    
    UserDefaults.standard.set(userDict, forKey: CURRENTUSER)
    UserDefaults.standard.synchronize()
}

//MARK: Update User

func updateCurrentUserFierstore(withValues: [String: Any], completion: @escaping (_ error: Error?) -> Void) {
    
    if let dict = UserDefaults.standard.object(forKey: CURRENTUSER) {
        
        let userObject = (dict as! NSDictionary).mutableCopy() as! NSMutableDictionary
        userObject.setValuesForKeys(withValues)
        
        firebaseRef(.User).document(User.currentUserId()).updateData(withValues) { (error) in
            
            completion(error)
            
            if error == nil {
                saveUserLocally(userDict: userObject)
            }
        }
    }
}
