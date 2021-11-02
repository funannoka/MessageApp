//
//  ViewController.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/19/21.
//

import UIKit
import Photos
import Firebase
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import Kingfisher

class ChatViewController: UIViewController {//MessagesViewController {

    @IBOutlet weak var profileImageContainer: UIView!
    @IBOutlet weak var profileImage: CircularImageView!
    @IBOutlet weak var profileImageLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userStatusLabel: UILabel!
    
    var user: User?
    var tappedUser: User?
    var  channel: Channel?
    
    let database = Firestore.firestore()
    var reference: CollectionReference?
    let storage = Storage.storage().reference()

    var messages: [Message] = []
    var messageListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.hidesBackButton = false
        navigationItem.setHidesBackButton(false, animated: false)
//        messagesCollectionView.messagesDataSource = self
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
        loadUserInfoUIView ()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
//
//    let sender = Sender(senderId: "any_unique_id", displayName: "Steven")
//    let messages = [Message(sender:  Sender(senderId: "any_unique_id", displayName: "Steven"), messageId: "!!!!!", sentDate: Date.now, kind: MessageKind.emoji("🍀")), Message(sender:  Sender(senderId: "my_unique_id", displayName: "Funa"), messageId: "!!%%5!", sentDate: Date.now, kind: MessageKind.text("Ayyyyye!"))]


    func loadUserInfoUIView () {
        profileImageContainer.circular()
       
            if let channel = channel {
                if (channel.type == 1) {
                    if let user = self.tappedUser {
                        if let photoURL = user.photoURL {
                                let url = URL(string: photoURL)
                                profileImage.kf.setImage(with: url)
                        } else {
                            let first = user.firstName
                           let last = user.lastName
                            profileImageLabel.text = first[first.index(first.startIndex, offsetBy: 0)].uppercased() + last[last.index(last.startIndex, offsetBy: 0)].uppercased()
                        }
                        userNameLabel.text = user.firstName
                        userStatusLabel.text = "Registered on Message app"  //user.status
                    }
                } else {
                    if let photoURL = channel.photoURL {
                            let url = URL(string: photoURL)
                            profileImage.kf.setImage(with: url)
                    } else {
                        profileImageLabel.text = "?"
                    }
                    userNameLabel.text = channel.name
                    userStatusLabel.text = "Registered on Message app"  //user.status
                    
                }
            }
        }
}


//extension ChatViewController: MessagesDataSource {
//
//    func currentSender() -> SenderType {
//        return sender
//    }
//
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return messages[indexPath.section]
//    }
//
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//        return messages.count
//    }
//
//
//}
//
//extension ChatViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {
//
//}

