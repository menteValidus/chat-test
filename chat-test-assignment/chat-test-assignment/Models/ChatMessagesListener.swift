//
//  ChatMessagesListener.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import SendBirdSDK

protocol ChatMessagesListener: AnyObject {
    var lastReceivedMessagePublisher: Published<String?>.Publisher { get }
}

final class SendBirdChatMessagesListener: NSObject, ChatMessagesListener {
    
    var lastReceivedMessagePublisher: Published<String?>.Publisher { $lastReceivedMessage }
    
    @Published
    private var lastReceivedMessage: String?
    
    override init() {
        super.init()
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
    }
    
    deinit {
        print("Deinited")
    }
}

extension SendBirdChatMessagesListener: SBDChannelDelegate {
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        lastReceivedMessage = message.message
    }
}
