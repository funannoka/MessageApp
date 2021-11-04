//
//  NewChatViewController.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/24/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import Kingfisher

class SearchViewController:  UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, TabBarReselectHandling {

    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    var users: [User] = []
    var currentUser: FirebaseAuth.User?
    var user: User?
    var tappedUser: User?
    var realData: [User] = []
    let db = Firestore.firestore()
    var channels: [Channel] = []
    var channel: Channel?
    var channelReference: CollectionReference {
      return db.collection("channel")
    }
    var userReference: CollectionReference {
      return db.collection("users")
    }
    var handle: AuthStateDidChangeListenerHandle?
    var channelListener: ListenerRegistration?
    var userListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search"
        self.title = "Search"
        currentUser = Auth.auth().currentUser
        loadCurentUser()
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        hideKeyboardWhenTappedAround()
//        addUserListener()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: animated)
//        navigationItem.hidesBackButton = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { auth, user in

        }
      //  loadCurentUser()
        addUserListener()
        addChannelListener()
        if let u = Auth.auth().currentUser {
            channelListener = channelReference.document(u.uid).addSnapshotListener() { (querySnapshot, err) in
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        channelListener?.remove()
        userListener?.remove()
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadCurentUser () {
//        var loggedUser: User?
        if let currentUser = self.currentUser {
            userReference.document(currentUser.uid).addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if let doc = querySnapshot {
                        self.user = User(document: doc)!
                    }
                }
            }
        }
//        let user = loggedUser!
    }
    
    func addChannelListener(){
        if let user = self.currentUser {
            channelListener = channelReference.whereField("members", arrayContains: user.uid).whereField("type", isEqualTo: 1)
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
    
    func addChannelToCollection(_ channel: Channel) {
        if channels.contains(channel) { //where: { $0.id == channel.id}
          return
        }

        channels.append(channel)
        channels.sort()//{ $0.modifiedAt < $1.modifiedAt }

//        guard let index = channels.firstIndex(of: channel) else {
//          return
//        }
//        collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func updateChannelInCollection(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else {
          return
        }

        channels[index] = channel
//        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func removeChannelFromCollection(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else {
          return
        }

        channels.remove(at: index)
//        collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
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
    
//    func createChannel() {
//        guard let user = self.user, let tappedUser = self.tappedUser
////            guard
////              let alertController = currentChannelAlertController,
////              let channelName = alertController.textFields?.first?.text
//            else {
//              return
//            }
//
//            let channel = Channel(user: user, tappedUser: tappedUser)
//            do {
//                try channelReference.document(channel.id).setData(from: channel)
//                    userReference.document(user.uid).updateData([
//                    "channels": FieldValue.arrayUnion([channel.id])])
//            } catch let error {
//                print("Error saving channel:\(error.localizedDescription)")
//            }
//    }
    
    func getChannel () {
        guard let user = self.user, let tappedUser = self.tappedUser else {
            return
        }
        let arr = [user.uid,tappedUser.uid]
        self.channel = nil
        guard let index = channels.firstIndex(where: {$0.members.sorted() == arr.sorted()}) else {
            print("channel NOT found")
            let channel = Channel(user: user, tappedUser: tappedUser)
            do {
                try channelReference.document(channel.id).setData(from: channel)
                    userReference.document(user.uid).updateData(["channels": FieldValue.arrayUnion([channel.id])])
                    userReference.document(tappedUser.uid).updateData(["channels": FieldValue.arrayUnion([channel.id])])
            } catch let error {
                print("Error saving channel:\(error.localizedDescription)")
            }
            //channels.append(channel)
           // channels.sort()//{ $0.modifiedAt < $1.modifiedAt }
            self.channel = channel
          return
        }
        print("channel found")
        self.channel = channels[index]
        
    }
    
    
    func addUserListener() {
        userListener = userReference.order(by: "firstName")
            .addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    self.users = []
                    self.realData = []
                    for document in snapshotDocuments {
                        if let user = User(document: document) {
                        self.realData.append(user)
                        }
                    }
                }
            }
        }
    }
    

//}

//extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func handleReselect() {
        self.searchCollectionView?.setContentOffset(.zero, animated: true)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "searchCollectionCell", for: indexPath) as! SearchCollectionViewCell
        let user = users[indexPath.item]
        cell.setUser(user: user)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: SearchCollectionViewCell = collectionView.cellForItem(at: indexPath as IndexPath) as! SearchCollectionViewCell
        if let tappedUser = cell.getUser() {
        self.tappedUser = tappedUser
            self.getChannel()
            performSegue(withIdentifier: "searchToChat", sender: self)
         }
    
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ChatViewController
        if let user = self.user, let tappedUser = self.tappedUser, let channel = self.channel {
        vc.user = user
        vc.tappedUser = tappedUser
        vc.sender = Sender(senderId: user.uid, displayName: user.firstName)
        vc.channel = channel
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        switch kind {

        case UICollectionView.elementKindSectionHeader:

            let searchView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "searchBarIdentifier", for: indexPath)
            
//            if indexPath.section == 1
//            {
//                searchView.isHidden = true
//                    }
            return searchView
//        let searchView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "searchBarIdentifier", for: indexPath)
        default:

            assert(false, "Unexpected element kind")
        }
//        if indexPath.section == 1
//        {
//            searchView.isHidden = true
//        }
//        return searchView
    }
    
//}

//extension SearchViewController: UISearchBarDelegate {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       // searchBar.showsCancelButton = true
        searchBar.endEditing(true)
        self.users.removeAll()
        for item in self.realData {
            let name = item.firstName + " " + item.lastName
            if (name.lowercased().contains(searchBar.text!.lowercased())) {
                self.users.append(item)
            }
        }
        if (searchBar.text!.isEmpty) {
            self.users.removeAll()
            //self.users = self.realData
        }
        self.searchCollectionView.reloadSections([1])
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        self.users.removeAll()
//        self.users = self.realData
        self.searchCollectionView.reloadSections([1])
    //  self.dismiss(animated: true, completion: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
 
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.users.removeAll()
        for item in self.realData {
            let name = item.firstName + " " + item.lastName
            if (name.lowercased().contains(searchBar.text!.lowercased())) {
                self.users.append(item)

            }
        }

        if (searchBar.text!.isEmpty) {
            self.users.removeAll()
        }
        self.searchCollectionView.reloadSections([1])

    }
}



extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width  = collectionView.frame.width
        return CGSize(width: width * 0.9, height: 50)
    }
    
    //custom dimensions searchbar/collectionView header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return section == 0 ? CGSize(width: collectionView.frame.width , height: 44 + 40) : CGSize(width: collectionView.frame.width, height: 0)
    }
}

