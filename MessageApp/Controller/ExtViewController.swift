//
//  ViewController.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/25/21.
//

import UIKit

extension UIViewController {
    
    func seperateWithWhiteSpace (n: String) -> [String] {
        var  arr: [String]
        let whitespace = CharacterSet.whitespaces
        let range = n.rangeOfCharacter(from: whitespace)
        if let _ = range {
            arr = n.components(separatedBy: whitespace)
        } else {
            arr = [n, ""]
        }
        return arr
    }

    func getInitial (first: String, last: String) -> String {
        let initial = first[first.index(first.startIndex, offsetBy: 0)].uppercased() + last[last.index(last.startIndex, offsetBy: 0)].uppercased()
        return initial
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)

        if let nav = self.navigationController {
            nav.view.endEditing(true)
        }
    }
 }
