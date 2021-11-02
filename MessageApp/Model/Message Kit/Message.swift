//
//  Message.swift
//  MessageApp
//
//  Created by Funa Nnoka on 10/19/21.
//

import Foundation
import MessageKit

public struct Message: MessageType {
   
    public let sender: SenderType
    
    public let messageId: String

    public let sentDate: Date

    public let kind: MessageKind
}


