//
//  CircularImageView.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/21/21.
//

import UIKit

@IBDesignable
class CircularImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2.0
        self.clipsToBounds = true
//        self.layer.masksToBounds = true

    }

}

extension UIView {
    func circular (
        borderwidth: CGFloat = 2.0,
        bordercolor: CGColor = UIColor.lightGray.cgColor //systemPink
    ) {
        self.layer.cornerRadius = (self.frame.size.width / 2.0)
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        
        self.layer.borderColor = bordercolor
        self.layer.borderWidth = borderwidth
    }
}
