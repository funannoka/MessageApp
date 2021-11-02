//
//  RegisterViewController.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/19/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profilePhotoImageView: CircularImageView!
    @IBOutlet weak var ImageLabel: UILabel!
    @IBOutlet weak var profilePhotoContainerView: UIView!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var storageRef : StorageReference = Storage.storage().reference()
    var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        profilePhotoContainerView.circular()
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
//        var user: User?
        if let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let phone = phoneTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    let nameArr = self.seperateWithWhiteSpace(n: name)
                    if let uid = authResult?.user.uid {
                        let imageName = UUID().uuidString
                        let imageRef = self.storageRef.child("images").child("profile_images").child("\(imageName).png")
                        let usersRef = self.db.collection("users")

                        
                    if let uploadData = self.profilePhotoImageView.image?.pngData() {
                        imageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                            imageRef.downloadURL { (url, error) in
                                if let downloadURL = url {
                                    let user = User(firstName: nameArr[0], lastName: nameArr[1], phone: phone, email: email, photoURL: downloadURL.absoluteString, uid: uid, channels: [])
                                    do {
                                        try usersRef.document(uid).setData(from: user)
                                    } catch let error {
                                        print("\(error.localizedDescription)")
                                    }
//                                usersRef.document(uid).setData([
//                                    "photoURL": downloadURL.absoluteString
//                                ], merge: true) { (error) in
//                                    if let e = error {
//                                        print("\(e.localizedDescription)")
//                                    } else {
//                                        print("Successfully saved data")
//                                    }
//                                }
                                }

                            }
                        }
                    } else {
                        let user = User(firstName: nameArr[0], lastName: nameArr[1], phone: phone, email: email, photoURL: nil, uid: uid, channels: nil)
                        do {
                            try usersRef.document(uid).setData(from: user)
                        } catch let error {
                            print("\(error.localizedDescription)")
                        }
                    }
                    
                    self.performSegue(withIdentifier: "RegisterToHome", sender: self)
                }
            }
        }
        }
    }
    
    @IBAction func uploadImagePressed(_ sender: Any) {
        self.imagePicker.present(from: sender as! UIView)
    }
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RegisterViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.profilePhotoImageView.image = image
    }
}
