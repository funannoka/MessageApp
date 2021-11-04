//
//  ChannelsCollectionViewCell.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/23/21.
//

import UIKit
import Kingfisher

class ChannelsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileImageContainer: UIView!
    @IBOutlet weak var profileImage: CircularImageView!
    @IBOutlet weak var profileImageLabel: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var messagePreviewLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var tappedChannel: Channel?
    var tappedUser: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageContainer.circular()
    }
    
    func getChannel() -> Channel {
        let channel = tappedChannel!
        return channel
    }
    
    func getTappedUser() -> User? {
        let user = tappedUser
        return user
    }
    
    func updateCell (channel: Channel, user: User?) {
        tappedChannel = channel
        tappedUser = user
            if channel.type == 1 {
                if let user = user {
                    senderLabel.text = "\(user.firstName) \(user.lastName)"
                    if let recentMessage = channel.recentMessage {
                        if let userRecentMessage = recentMessage[user.uid] {
                        messagePreviewLabel.text = userRecentMessage.body
                        }
                    }
                    if let photoURL = user.photoURL {
                            let url = URL(string: photoURL)
                            profileImage.kf.setImage(with: url)
                    } else {
                        profileImageLabel.text = getInitial(first: user.firstName, last: user.lastName)
                    }
                }
                
            } else {
                senderLabel.text = channel.name
                if let recentMessage = channel.recentMessage {
                    if let mostRecentMessage = recentMessage["recent"] {
                        messagePreviewLabel.text = String("\(mostRecentMessage.sender.name): \(mostRecentMessage.body)")
                        if let photoURL = mostRecentMessage.sender.photo {
                                let url = URL(string: photoURL)
                                profileImage.kf.setImage(with: url)
                        } else {
                            let nameArr = seperateWithWhiteSpace(n: mostRecentMessage.sender.name)
                           
                            profileImageLabel.text = getInitial(first: nameArr[0], last: nameArr[1])
                        }
                    }
                } else {
                    print("channel.recentMessage is nil")
                        senderLabel.text = channel.name
                        profileImageLabel.text = "?"
                        messagePreviewLabel.font = UIFont.italicSystemFont(ofSize: 12)
                        messagePreviewLabel.text = "no message has been sent."
                }
            }
            let date = Date(seconds: channel.modifiedAt)
            let dateArr = date.secondsToDayYearTime
            dayLabel.text = dateArr[0]
            timeLabel.text = dateArr[2]
            
    }
    
    
    
}

extension Date {
 var secondsSince1970:Double {
        return Double((self.timeIntervalSince1970).rounded())
    }

    init(seconds:Double) {
        self = Date(timeIntervalSince1970: TimeInterval(seconds))
    }
    
    func seperateDayYearTime (date: String) -> [String] {
        //"Oct 15, 2021 at 10:44 AM
        let components = date.components(separatedBy: ", ")
        let day = components[0]
        let comp = components[1].components(separatedBy: " at ")
        let seperatedDate = [day, comp[0], comp[1]]
        return seperatedDate
    }
    
    var secondsToDayYearTime: [String] {
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .medium
        //dateFormatter.dateFormat = "Y, MMM d, hh:mm "
        dateFormatter.timeStyle = .short

        let formattedDate = dateFormatter.string(from: self)
        let dateArr = seperateDayYearTime(date: formattedDate)
        
        return dateArr
    }
}

//Date().millisecondsSince1970 // 1476889390939
//Date(milliseconds: 0) // "Dec 31, 1969, 4:00 PM" (PDT variant of 1970 UTC)
