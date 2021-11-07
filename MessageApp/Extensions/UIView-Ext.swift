//
//  UIView-Ext.swift
//  MessageApp
//
//  Created by Funa Nnoka on 11/4/21.
//

import UIKit

extension UIView {
    func smoothRoundCorners(to radius: CGFloat) {
    let maskLayer = CAShapeLayer()
    maskLayer.path = UIBezierPath(
      roundedRect: bounds,
      cornerRadius: radius
    ).cgPath

    layer.mask = maskLayer
    }
    
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
