//
//  Group.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/24/21.
//

import Foundation
import FirebaseFirestore


public struct Channel: Codable {

    let createdAt: Double
    let createdBy: String
    let id: String
    let members: [String]
    let modifiedAt: Double
    let name: String?
    let type: Int
    let photoURL: String?
    //let recentMessage: RecentMessage?
    let recentMessage: [String: RecentMessage]?

    init(name: String, creatorUID: String) {
        self.createdAt = Date().timeIntervalSince1970
        self.createdBy = creatorUID
        self.id = UUID().uuidString
        self.members = [creatorUID]
        self.modifiedAt = Date().timeIntervalSince1970
        self.name = name
        self.type = 2
        self.photoURL = nil
        self.recentMessage = nil//["recent": RecentMessage(body: "", viewers: nil, date: Date().timeIntervalSince1970, sender: SenderInfo(name: "", id: "", photo: ""))]
        //[creatorUID: RecentMessage(body: "This is a test 🧝🏿‍♀️", viewers: nil, date: Date().timeIntervalSince1970, sender: SenderInfo(name: "Funa Nnoka", id: creatorUID, photo: nil))]
    }
    
    init?(document: DocumentSnapshot) {
        let result = Result {
            try document.data(as: Channel.self)
        }
        
        switch result {
            case .success(let channelInfo):
                if let channelInfo = channelInfo {
                    print("channel: \(channelInfo)")
                    self.createdAt = channelInfo.createdAt
                    self.createdBy = channelInfo.createdBy
                    self.id = channelInfo.id
                    self.members = channelInfo.members
                    self.modifiedAt = channelInfo.modifiedAt
                    self.name = channelInfo.name
                    self.type = channelInfo.type
                    self.photoURL = channelInfo.photoURL
                    self.recentMessage = channelInfo.recentMessage
                } else {
                    
                    print("Document does not exist")
                    return nil
                }
            case .failure(let error):
                print("Error decoding channels: \(error)")
                return nil
        }
    }
    
    init(user: User, tappedUser: User) {
        self.createdAt = Date().timeIntervalSince1970
        self.createdBy = user.uid
        self.id = UUID().uuidString
        self.members = [user.uid,tappedUser.uid]
        self.modifiedAt = Date().timeIntervalSince1970
        self.name = nil
        self.type = 1
        self.photoURL = nil
        self.recentMessage = nil//["recent": RecentMessage(body: "", viewers: nil, date: Date().timeIntervalSince1970, sender: SenderInfo(name: "", id: "", photo: ""))]//[tappedUser.uid: RecentMessage(body: "This is a damn test 🧝🏿‍♀️", viewers: nil, date: Date().timeIntervalSince1970, sender: SenderInfo(name: "\(tappedUser.firstName) \(tappedUser.lastName)", id: tappedUser.uid, photo: nil)), "recent": RecentMessage(body: "Test: Most recent message 🧝🏿‍♀️", viewers: nil, date: Date().timeIntervalSince1970, sender: SenderInfo(name: "\(user.firstName) \(user.lastName)", id: user.uid, photo: nil))]
    }

}


public struct RecentMessage: Codable {
    
    let body: String
    let viewers: [String]?
    let date: Double
    let sender: SenderInfo
    
    
    init(user: User, message: Message) {
        let name = "\(user.firstName) \(user.lastName)"
        self.body = message.content
        self.date = message.sentDate.timeIntervalSince1970
        self.sender = SenderInfo(name: name, id: user.uid, photo: user.photoURL)
        self.viewers = nil
    }
    
    init?(document: DocumentSnapshot) {
        let result = Result {
            try document.data(as: RecentMessage.self)
        }
        
        switch result {
            case .success(let messageInfo):
                if let messageInfo = messageInfo {
                    print("recentMessageInfo: \(messageInfo)")
                    self.body = messageInfo.body
                    self.viewers = messageInfo.viewers
                    self.date = messageInfo.date
                    self.sender = messageInfo.sender
                   
                } else {
                    
                    print("RecentMessage Document does not exist for this channel")
                    return nil
                }
            case .failure(let error):
                print("Error decoding RecentMessage: \(error)")
                return nil
        }
    }
}

public struct SenderInfo: Codable {
    let name: String
    let id: String
    let photo: String?
}

//// MARK: - DatabaseRepresentation
//extension Channel: DatabaseRepresentation {
//    var representation: [String: Any] {
//      
//        var rep = ["createdAt": createdAt, "createdBy": createdBy, "id": id, "members": members, "modifiedAt": modifiedAt, "type": type] as [String : Any]
//
//    if let name = name {
//        rep["name"] = name
//    }
//    if let photoURL = photoURL {
//        rep["photoURL"] = photoURL
//    }
//    if let recentMessage = recentMessage {
//      rep["recentMessage"] = recentMessage
//    }
//
//    return rep
//  }
//}

extension Channel: Comparable {
    public static func < (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.modifiedAt > rhs.modifiedAt
    }
    
    public static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id == rhs.id
    }
}
