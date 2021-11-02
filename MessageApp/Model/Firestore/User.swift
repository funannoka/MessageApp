//
//  User.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/20/21.
//

import Foundation
import FirebaseFirestore

public struct User: Codable {

    let firstName: String
    let lastName: String
    let phone: String
    let email: String
    let photoURL: String?
    let uid: String
    let channels: [String]?
    
    init(firstName: String, lastName: String, phone: String, email: String, photoURL: String?, uid: String, channels: [String]?) {
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
        self.photoURL = photoURL
        self.uid = uid
        self.channels = channels
    }
    //DocumentSnapshot
    init?(document: DocumentSnapshot) {
        let result = Result {
            try document.data(as: User.self)
        }
        
        switch result {
            case .success(let userInfo):
                if let userInfo = userInfo {
                    print("userInfo: \(userInfo)")
                    self.firstName = userInfo.firstName
                    self.lastName = userInfo.lastName
                    self.phone = userInfo.phone
                    self.email = userInfo.email
                    self.photoURL = userInfo.photoURL
                    self.uid = userInfo.uid
                    self.channels = userInfo.channels
                } else {
                    
                    print("Document does not exist")
                    return nil
                }
            case .failure(let error):
                print("Error decoding userInfo: \(error)")
                return nil
        }
    }

}
