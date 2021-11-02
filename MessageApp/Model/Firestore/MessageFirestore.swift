//
//  Message.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/24/21.
//

import Foundation

public struct MessageFirestore: Codable {
    
    let body: String
    let date: String
    let sender: String
    let id: String

}
