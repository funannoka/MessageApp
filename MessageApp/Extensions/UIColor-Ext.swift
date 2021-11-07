//
//  UIColor-Ext.swift
//  MessageApp
//
//  Created by Funa Nnoka on 11/4/21.
//

import UIKit

extension UIColor {
  static var primary: UIColor {
    // swiftlint:disable:next force_unwrapping
    return UIColor(named: "rw-blue")!
  }

  static var incomingMessage: UIColor {
    // swiftlint:disable:next force_unwrapping
    return UIColor(named: "incoming-message")!
  }
}
