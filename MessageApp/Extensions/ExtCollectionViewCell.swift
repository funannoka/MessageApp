//
//  ExtCollectionViewCell.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/30/21.
//

import UIKit

extension UICollectionViewCell {
    
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
}
