//
//  SearchCollectionViewCell.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/25/21.
//

import UIKit
import Kingfisher

class SearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageContainer: UIView!

    @IBOutlet weak var profileImage: CircularImageView!
    
    @IBOutlet weak var profileImageLabel: UILabel!
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageContainer.circular()
    }
    var tappedUser: User?
    
    
     func setUser(user: User) {
         if let photoURL = user.photoURL {
             let url = URL(string: photoURL)
             profileImage.kf.setImage(with: url)
         } else {
             let first = user.firstName
            let last = user.lastName
             profileImageLabel.text = getInitial(first: first, last: last)
         }
         userLabel.text = user.firstName
         infoLabel.text = "Registered on Message app"  //user.status
         tappedUser = user
     }
     
     func getUser() -> User {
         let user = tappedUser!
         return user
     }

}
