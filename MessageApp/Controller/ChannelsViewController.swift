//
//  HomeViewController.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/19/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Kingfisher

class ChannelsViewController: UIViewController {

    @IBOutlet weak var profileImageContainerView: UIView!
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var profileImageLabel: UILabel!
    @IBOutlet weak var newChatButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
//    var messages: [Message] = []
    var userInfo: User?
    var tappedUser: User?
    var userAtCell: User?
    var currentUser: Firebase.User?
    var channels: [Channel] = []
    var currentChannelAlertController: UIAlertController?
    var tappedChannel: Channel?
    var recentMessage: RecentMessage?
    let db = Firestore.firestore()
    var channelReference: CollectionReference {
      return db.collection("channel")
    }
    var userReference: CollectionReference {
      return db.collection("users")
    }
    var recentMessageReference: CollectionReference?
    var handle: AuthStateDidChangeListenerHandle?
    var channelListener: ListenerRegistration?
    var userListener: ListenerRegistration?
    var messageListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = "Channels"
        navigationItem.hidesBackButton = true
        collectionView.dataSource = self
        collectionView.delegate = self

        currentUser = Auth.auth().currentUser
        profileImageContainerView.circular()
        loadUser()
//        addChannelListener()
//        loadGroups()
        collectionView.register(UINib(nibName: "ChannelsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ReusableCell")
        self.title = "Channels"
        //self.collectionView.reloadData()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(true, animated: animated)
        //self.tabBarController?.navigationItem.title
//        navigationItem.hidesBackButton = true

        addChannelListener()

        handle = Auth.auth().addStateDidChangeListener { auth, user in

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: animated)
//        navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        navigationItem.hidesBackButton = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        channelListener?.remove()
        userListener?.remove()
        messageListener?.remove()

    }
    
    
    func addChannelListener(){
        if let user = self.currentUser {
            channelListener = channelReference.whereField("members", arrayContains: user.uid)
               //.order(by: "modifiedAt", descending: true)
                .addSnapshotListener() { (querySnapshot, err) in
                    if let err = err {
                        print("Error listening for channel updates: \(err.localizedDescription)")
                    } else {
                        if let snapshot = querySnapshot {
                            snapshot.documentChanges.forEach { change in
                              self.handleDocumentChange(change)
                            }
                        }
                    }
                }
        }
    }
    
    func loadUser () {
        if let user = self.currentUser {
            userListener = userReference.document(user.uid).addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    let result = Result {
                        try querySnapshot?.data(as: User.self)
                    }
                    switch result {
                    case .success(let userInfo):
                        if let userInfo = userInfo {
                            self.userInfo = userInfo
                            print("User: \(userInfo)")
                            if let photoURL = userInfo.photoURL {
                                let url = URL(string: photoURL)
                                DispatchQueue.main.async {
                                    self.profileImageView.kf.setImage(with: url)
//                                    self.collectionView.reloadData()
                                }
                            } else {
                                let first = userInfo.firstName
                               let last = userInfo.lastName
                                DispatchQueue.main.async {
                                    self.profileImageLabel.text = self.getInitial(first: first, last: last)
                                }
                            }
                        } else {
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding currentUser: \(error)")
                    }
                }
            }
        } else {
            print("currentUser is nil")
        }
    }
        
//    func loadGroups () {
//        if let user = self.currentUser {
//            channelListener = channelReference.whereField("members", arrayContains: user.uid)
//                .order(by: "modifiedAt", descending: true)
//                .addSnapshotListener() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//                } else {
//                    if let snapshotDocuments = querySnapshot?.documents {
//                        self.channels = []
//                        for document in snapshotDocuments {
//    //                        print("\(document.documentID) => \(document.data())")
//                            let result = Result {
//                                try document.data(as: Channel.self)
//                            }
//                            
//                            switch result {
//                            case .success(let channelInfo):
//                                if let channelInfo = channelInfo {
//                                    print("channel: \(channelInfo)")
//                                        
////                                        let channel = Channel(createdAt: channelInfo.createdAt, createdBy: channelInfo.createdBy, id: channelInfo.id, members: channelInfo.members, modifiedAt: channelInfo.modifiedAt, name: channelInfo.name, type: channelInfo.type, recentMessage: channelInfo.recentMessage)
//                                        self.channels.append(channelInfo)
//                                        print(self.channels)
//
//                                        DispatchQueue.main.async {
//                                            self.collectionView.reloadData()
//                                            self.collectionView.scrollsToTop = true
//                                        }
//                                    
//                                } else {
//                                    print("Document does not exist")
//                                }
//                            case .failure(let error):
//                                print("Error decoding channels: \(error)")
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
    @objc private func textFieldDidChange(_ field: UITextField) {
      guard let alertController = currentChannelAlertController else {
        return
      }
      alertController.preferredAction?.isEnabled = field.hasText
    }
    
    
    func addChannelToCollection(_ channel: Channel) {
        if channels.contains(channel) { //where: { $0.id == channel.id}
          return
        }

        channels.append(channel)
        channels.sort()//{ $0.modifiedAt < $1.modifiedAt }

        guard let index = channels.firstIndex(of: channel) else {
          return
        }
        collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func updateChannelInCollection(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else {
          return
        }

        channels[index] = channel
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func removeChannelFromCollection(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else {
          return
        }

        channels.remove(at: index)
        collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func handleDocumentChange(_ change: DocumentChange) {
      guard let channel = Channel(document: change.document) else {
        return
      }

      switch change.type {
      case .added:
          addChannelToCollection(channel)
      case .modified:
          updateChannelInCollection(channel)
      case .removed:
        removeChannelFromCollection(channel)
      }
    }
    
    func createChannel() {
        if let user = self.currentUser {
            guard
              let alertController = currentChannelAlertController,
              let channelName = alertController.textFields?.first?.text
            else {
              return
            }

            let channel = Channel(name: channelName, creatorUID: user.uid)
            do {
                try channelReference.document(channel.id).setData(from: channel)
                    userReference.document(user.uid).updateData([
                    "channels": FieldValue.arrayUnion([channel.id])])
            } catch let error {
                print("Error saving channel:\(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func newChatButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Create a New Channel", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField { field in
          field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
          field.enablesReturnKeyAutomatically = true
          field.autocapitalizationType = .words
          field.clearButtonMode = .whileEditing
          field.placeholder = "Channel Name"
          field.returnKeyType = .done
            field.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        }

        let createAction = UIAlertAction(
          title: "Create",
          style: .default) { _ in
          self.createChannel()
        }
        createAction.isEnabled = false
        alertController.addAction(createAction)
        alertController.preferredAction = createAction

        present(alertController, animated: true) {
          alertController.textFields?.first?.becomeFirstResponder()
        }
        currentChannelAlertController = alertController
    }
}




extension ChannelsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, TabBarReselectHandling {
    
    func handleReselect() {
        self.collectionView.setContentOffset(.zero, animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ChannelsCollectionViewCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "ReusableCell", for: indexPath) as! ChannelsCollectionViewCell
        let channel = channels[indexPath.item]
        recentMessageReference = db.collection("channel/\(channel.id)/recentMessage/")
        self.recentMessage = nil
        if (channel.type == 1) {
            if let user = self.currentUser {
                let members = channel.members
                if let index = members.firstIndex(where: { $0 != user.uid }) {
                    let tappedUserId = members[index]
                    userReference.document(tappedUserId).getDocument { documentSnapshot, error in
                        if let err = error {
                            print("Error getting documents: \(err)")
                        } else {
                            guard let snapshot = documentSnapshot else {
                              print("Error listening for user updates")
                                return
                            }
                            guard let tappedUser = User(document: snapshot) else {
                              return
                            }
//                            self.userAtCell = tappedUser
                            self.channelReference.document(channel.id).collection("recentMessage").document(tappedUser.uid).addSnapshotListener()  { snapshotDoc, err in
                                if let err = err {
                                    print("Error getting documents: \(err.localizedDescription)")
                                } else {
                                guard let snapshot = snapshotDoc else {
                                  print("Error listening for recentMessage updates")
                                    return
                                }
                                guard let recentMessage = RecentMessage(document: snapshot)
                                else {
                                    cell.updateCell(channel: channel, user: tappedUser, recentMessage: nil)
                                  return
                                }
                                    cell.updateCell(channel: channel, user: tappedUser, recentMessage: recentMessage)
                                }
                            }
//                            cell.updateCell(channel: channel, user: tappedUser, recentMessage: self.recentMessage)
                        }
                    }
                        
                }
            }
            
        } else {
            self.channelReference.document(channel.id).collection("recentMessage").document("recent").addSnapshotListener()  { snapshotDoc, err in
                if let err = err {
                    print("Error getting documents: \(err.localizedDescription)")
                } else {
                guard let snapshot = snapshotDoc else {
                  print("Error listening for recentMessage updates")
                    return
                }
                guard let recentMessage = RecentMessage(document: snapshot)
                else {
                    cell.updateCell(channel: channel, user: nil, recentMessage: nil)
                  return
                }
                    cell.updateCell(channel: channel, user: nil, recentMessage: recentMessage)
                }
            }
            
//            cell.updateCell(channel: channels[indexPath.item], user: nil, recentMessage: self.recentMessage)

        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: ChannelsCollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath) as! ChannelsCollectionViewCell
        self.tappedChannel = cell.getChannel()
        if let tappedUser = cell.getTappedUser() {
            self.tappedUser = tappedUser
            
        }
        performSegue(withIdentifier: "homeToChat", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ChatViewController
        if let user = self.userInfo, let channel = self.tappedChannel {
            if channel.type == 1 {
                guard let tappedUser = self.tappedUser
                else { return }
                    vc.tappedUser = tappedUser
                    vc.user = user
                    vc.channel = channel
                    vc.sender = Sender(senderId: user.uid, displayName: user.firstName)
            } else {
                vc.user = user
                vc.channel = channel
                vc.sender = Sender(senderId: user.uid, displayName: user.firstName)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//            let height = collectionView.frame.height
            let width  = collectionView.frame.width
        return CGSize(width: width * 0.93, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {

        case UICollectionView.elementKindSectionHeader:

            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerIdentifier", for: indexPath) as? ChannelsHeader {
                headerView.sectionHeaderLabel.text = "Channels"
                return headerView
            }

//            headerView.backgroundColor = UIColor.blue

        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerIdentifier", for: indexPath)
            
//            footerView.backgroundColor = UIColor.green
            return footerView

        default:

            assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
}
