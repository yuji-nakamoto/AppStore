//
//  Storage.swift
//  AppStore
//
//  Created by yuji_nakamoto on 2020/06/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

let storage = Storage.storage()

func uploadItemImages(images: [UIImage?], itemId: String, comletion: @escaping (_ imageUrls: [String]) -> Void) {
    
    if Reachabilty.HasConnection() {
        
        var uploadedImagesCount = 0
        var imageUrlsArray: [String] = []
        var nameSuffix = 0
        
        for image in images {
            
            let fileName = "ItemImages/" + itemId + "/" + "\(nameSuffix)" + "/jpg"
            let imageData = image!.jpegData(compressionQuality: 0.1)
            
            saveImageInFirebase(imageData: imageData!, fileName: fileName) { (imageUrl) in
                
                if imageUrl != nil {
                    
                    imageUrlsArray.append(imageUrl!)
                    uploadedImagesCount += 1
                    if uploadedImagesCount == images.count {
                        
                        comletion(imageUrlsArray)
                    }
                }
            }
            nameSuffix += 1
        }
    } else {
        print("No Internet Connection")
    }
}

func uploadProfileImages(image: UIImage?, completion: @escaping (_ imageUrl: String) -> Void) {
    
    if Reachabilty.HasConnection() {
        
        var imageUrlString: String!
        let fileName = "ProfileImage/\(User.currentUserId())/jpg"
        let imageData = image!.jpegData(compressionQuality: 0.1)
        
        saveImageInFirebase(imageData: imageData!, fileName: fileName) { (imageUrl) in
            
            if imageUrl != nil {
                
                imageUrlString = imageUrl!
                completion(imageUrlString)
            }
        }
    } else {
        print("No Internet Connection")
    }
}

func uploadHeaderImages(image: UIImage?, completion: @escaping (_ imageUrl: String) -> Void) {
    
    if Reachabilty.HasConnection() {
        
        var imageUrlString: String!
        let fileName = "HeaderImage/\(User.currentUserId())/jpg"
        let imageData = image!.jpegData(compressionQuality: 0.1)
        
        saveImageInFirebase(imageData: imageData!, fileName: fileName) { (imageUrl) in
            
            if imageUrl != nil {
                
                imageUrlString = imageUrl!
                completion(imageUrlString)
            }
        }
    } else {
        print("No Internet Connection")
    }
}


func saveImageInFirebase(imageData: Data, fileName: String, completion: @escaping (_ imageLink: String?) -> Void) {
    
    var task: StorageUploadTask!
    let storageRef = storage.reference(forURL: STORAGEREF).child(fileName)
    
    task = storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
        
        task.removeAllObservers()
        
        if error != nil {
            
            print("Error uploading image", error!.localizedDescription)
            completion(nil)
            return
        }
        storageRef.downloadURL { (url, error) in
            guard let downloadUrl = url else {
                completion(nil)
                return
            }
            completion(downloadUrl.absoluteString)
        }
    })
}

func downloadImages(imageUrls: [String], completion: @escaping (_ images: [UIImage?]) -> Void) {
    
    var imageArray: [UIImage] = []
    var downloadCounter = 0
    
    for link in imageUrls {
        
        let url = NSURL(string: link)
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            downloadCounter += 1
            
            let data = NSData(contentsOf: url! as URL)
            
            if data != nil {
                imageArray.append(UIImage(data: data! as Data)!)
                
                if downloadCounter == imageArray.count {
                    
                    DispatchQueue.main.async {
                        completion(imageArray)
                    }
                }
            } else {
                print("couldnt download image")
                completion(imageArray)
            }
        }
    }
}
