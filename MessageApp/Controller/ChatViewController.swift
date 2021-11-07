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

class ChatViewController: MessagesViewController {

    @IBOutlet weak var profileImageContainer: UIView!
    @IBOutlet weak var profileImage: CircularImageView!
    @IBOutlet weak var profileImageLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userStatusLabel: UILabel!
    var isSendingPhoto = false {
      didSet {
        messageInputBar.leftStackViewItems.forEach { item in
          guard let item = item as? InputBarButtonItem else {
            return
          }
          item.isEnabled = !self.isSendingPhoto
        }
      }
    }

    var user: User?
    var tappedUser: User?
    var  channel: Channel?
    
    let db = Firestore.firestore()
    var reference: CollectionReference?
    let storage = Storage.storage().reference()

    var messages: [Message] = []
    var messageListener: ListenerRegistration?
    var sender: Sender = Sender(senderId: "", displayName: "")
    var messageReference: CollectionReference {
      return db.collection("message")
    }
    var channelReference: CollectionReference {
      return db.collection("channel")
    }
    var recentMessageReference: CollectionReference?
    
    var handle: AuthStateDidChangeListenerHandle?
    var userListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.hidesBackButton = false
        navigationItem.setHidesBackButton(false, animated: false)
//        loadUserInfoUIView ()
        if let channel = channel {
            if (channel.type == 1) {
                if let user = self.tappedUser {
                    title = "\(user.firstName) \(user.lastName)" }
            } else {
                title = channel.name }
        }
//        if let user = self.user {
//            messages = [Message(user: user, content: "Well okay then")]
//        }
        listenToMessages()
        navigationItem.largeTitleDisplayMode = .never
        setUpMessageView()
        addAvatarView()
        removeMessageAvatars()
        addCameraBarButton()
        
//        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
//        addMessagelListener()

        handle = Auth.auth().addStateDidChangeListener { auth, user in

        }
    }

    
 
    override func viewWillDisappear(_ animated: Bool) {
//        navigationItem.hidesBackButton = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        messageListener?.remove()
        userListener?.remove()

    }
    
    func addAvatarView() {
        if let photoURL = tappedUser?.photoURL {
            
//            navigationItem.titleView?.circular()
            let url = URL(string: photoURL)

           let v = UIView()
            v.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
            v.frame.origin.x = CGFloat(0)
//            navigationItem.titleView = v
           // let v  = UIView()
             //   v.translatesAutoresizingMaskIntoConstraints = false
                // add your views and set up all the constraints
            v.layer.backgroundColor = UIColor.lightGray.cgColor
                // This is the magic sauce!
                v.layoutIfNeeded()
            v.sizeToFit()
            //v.sizeThatFits(CGSize(width: 50, height: 50)) //sizeThatFits sizeToFit

                // Now the frame is set (you can print it out)
            v.translatesAutoresizingMaskIntoConstraints = true // make nav bar happy
//            v.kf.setImage(with: url)
                v.circular()
            let s = CircularImageView()
            s.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
            s.frame.origin.x = CGFloat(0)
//            s.clipsToBounds = true
            s.kf.setImage(with: url)
            v.addSubview(s)
//            let titleLabel = UILabel()
//
//            let initials = getInitial(first: tappedUser!.firstName, last: tappedUser!.lastName)
//            titleLabel.text = initials
//            titleLabel.textColor = .primary
//            titleLabel.frame = CGRect(x: 48, y: 46, width: 45, height: 45)
//            titleLabel.frame.origin.x = CGFloat(48)
//            titleLabel.translatesAutoresizingMaskIntoConstraints = true // make nav bar happy
//            v.addSubview(titleLabel)
            //Stack View
      //      let stackView   = UIStackView()
//            stackView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//            stackView.frame.origin.x = CGFloat(0)
//            stackView.axis  = NSLayoutConstraint.Axis.horizontal
//            stackView.distribution  = UIStackView.Distribution.equalSpacing
//            stackView.alignment = UIStackView.Alignment.center
//            stackView.spacing   = 0
//
//            stackView.addArrangedSubview(v)
//            stackView.addArrangedSubview(titleLabel)
//            stackView.translatesAutoresizingMaskIntoConstraints = true
//
//
            navigationItem.titleView = v
        }
            
            navigationItem.backButtonTitle = ""
    }

    func setUpMessageView() {
      maintainPositionOnKeyboardFrameChanged = true
      messageInputBar.inputTextView.tintColor = .primary
      messageInputBar.sendButton.setTitleColor(.primary, for: .normal)

      messageInputBar.delegate = self
      messagesCollectionView.messagesDataSource = self
      messagesCollectionView.messagesLayoutDelegate = self
      messagesCollectionView.messagesDisplayDelegate = self
    }

    func removeMessageAvatars() {
      guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
        return
      }
//      layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
//      layout.textMessageSizeCalculator.incomingAvatarSize = .zero
//      layout.setMessageIncomingAvatarSize(.zero)
//      layout.setMessageOutgoingAvatarSize(.zero)
        
      let incomingLabelAlignment = LabelAlignment(
        textAlignment: .left,
        textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
      layout.setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)
      let outgoingLabelAlignment = LabelAlignment(
        textAlignment: .right,
        textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
      layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
    }

    func addCameraBarButton() {
      let cameraItem = InputBarButtonItem(type: .system)
      cameraItem.tintColor = .primary
      cameraItem.image = UIImage(named: "camera")
      cameraItem.addTarget(
        self,
        action: #selector(cameraButtonPressed),
        for: .primaryActionTriggered)
      cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)

      messageInputBar.leftStackView.alignment = .center
      messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
      messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
    
    func listenToMessages() {
        guard let id = channel?.id else {
        navigationController?.popViewController(animated: true)
        return
      }

      reference = db.collection("channel/\(id)/messages")

      messageListener = reference?.addSnapshotListener { [weak self] querySnapshot, error in
        guard let self = self else { return }
        guard let snapshot = querySnapshot else {
          print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
          return
        }

        snapshot.documentChanges.forEach { change in
          self.handleDocumentChange(change)
        }
      }
    }

    func handleDocumentChange(_ change: DocumentChange) {
      guard var message = Message(document: change.document) else {
        return
      }

      switch change.type {
      case .added:
        if let url = message.downloadURL {
          downloadImage(at: url) { [weak self] image in
            guard
              let self = self,
              let image = image
            else {
              return
            }
            message.image = image
            self.insertNewMessage(message)
          }
        } else {
          insertNewMessage(message)
        }
      default:
        break
      }
    }
    
    // MARK: - Actions
    @objc private func cameraButtonPressed() {
      let picker = UIImagePickerController()
      picker.delegate = self

      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        picker.sourceType = .camera
      } else {
        picker.sourceType = .photoLibrary
      }

      present(picker, animated: true)
    }

    // MARK: - Helpers
    func save(_ message: Message) {
        
        guard let user = self.user, let channel = self.channel else { return }
        recentMessageReference = db.collection("channel/\(channel.id)/recentMessage/")
        reference?.addDocument(data: message.representation) { [weak self] error in
        guard let self = self else { return }
        if let error = error {
          print("Error sending message: \(error.localizedDescription)")
          return
        }
        let recentMessage = RecentMessage(user: user, message: message)
        do {
            try self.recentMessageReference?.document(user.uid).setData(from: recentMessage)
            try self.recentMessageReference?.document("recent").setData(from: recentMessage)
        } catch let error {
            print("Error updating document: \(error)")
        }
//        self.channelReference.document(channel.id).updateData(["recentMessage.\(user.uid)": recentMessage])
//        self.channelReference.document(channel.id).updateData(["recent": recentMessage])
//        { err in
//            if let err = err {
//                print("Error updating document: \(err)")
//            } else {
//                print("Document successfully updated")
//            }
//        }
        self.messagesCollectionView.scrollToLastItem()
      }
    }

    func insertNewMessage(_ message: Message) {
      if messages.contains(message) {
        return
      }

      messages.append(message)
      messages.sort()

      let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
      let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage

      messagesCollectionView.reloadData()

      if shouldScrollToBottom {
        messagesCollectionView.scrollToLastItem(animated: true)
      }
    }

    
    func loadUserInfoUIView () {
        profileImageContainer.circular()
       
            if let channel = channel {
                if (channel.type == 1) {
                    if let user = self.tappedUser {
                        title = user.firstName

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
                    title = channel.name

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
    func uploadImage(
      _ image: UIImage,
      to channel: Channel,
      completion: @escaping (URL?) -> Void
    ) {
    let channelId = channel.id
      guard
        let scaledImage = image.scaledToSafeUploadSize,
        let data = scaledImage.jpegData(compressionQuality: 0.4)
      else {
        return completion(nil)
      }

      let metadata = StorageMetadata()
      metadata.contentType = "image/jpeg"

      let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
      let imageReference = storage.child("\(channelId)/\(imageName)")
      imageReference.putData(data, metadata: metadata) { _, _ in
        imageReference.downloadURL { url, _ in
          completion(url)
        }
      }
    }

    func sendPhoto(_ image: UIImage) {
      isSendingPhoto = true

        uploadImage(image, to: self.channel!) { [weak self] url in
        guard let self = self else { return }
        self.isSendingPhoto = false

        guard let url = url else {
          return
        }

            var message = Message(user: self.user!, image: image)
        message.downloadURL = url

        self.save(message)
        self.messagesCollectionView.scrollToLastItem()
      }
    }

    func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
      let ref = Storage.storage().reference(forURL: url.absoluteString)
      let megaByte = Int64(1 * 1024 * 1024)

      ref.getData(maxSize: megaByte) { data, _ in
        guard let imageData = data else {
          completion(nil)
          return
        }
        completion(UIImage(data: imageData))
      }
    }
  }


extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        return sender
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
      let name = message.sender.displayName
      return NSAttributedString(
        string: name,
        attributes: [
          .font: UIFont.preferredFont(forTextStyle: .caption1),
          .foregroundColor: UIColor(white: 0.3, alpha: 1)
        ])
    }
    
    
    


}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
    }

    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
      return false
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = false
        if let photoURL = isFromCurrentSender(message: message) ? user?.photoURL : tappedUser?.photoURL {
            let url = URL(string: photoURL)
            avatarView.kf.setImage(with: url)
        } else {
        avatarView.initials = isFromCurrentSender(message: message) ? getInitial(first: user!.firstName, last: user!.lastName) : getInitial(first: tappedUser!.firstName, last: tappedUser!.lastName)
        }
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
      let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
      return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
  func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    return CGSize(width: 0, height: 8)
  }

  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return 20
  }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    if let user = self.user {
        let message = Message(user: user, content: text)
        save(message)
        inputBar.inputTextView.text = ""
    }
  }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    picker.dismiss(animated: true)

    if let asset = info[.phAsset] as? PHAsset {
      let size = CGSize(width: 500, height: 500)
      PHImageManager.default().requestImage(
        for: asset,
        targetSize: size,
        contentMode: .aspectFit,
        options: nil
      ) { result, _ in
        guard let image = result else {
          return
        }
        self.sendPhoto(image)
      }
    } else if let image = info[.originalImage] as? UIImage {
      sendPhoto(image)
    }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
  }
}
