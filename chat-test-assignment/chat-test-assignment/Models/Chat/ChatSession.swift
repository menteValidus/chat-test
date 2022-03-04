//
//  ChatSession.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 28.02.2022.
//

import Foundation
import SendBirdSDK

protocol ChatSession: AnyObject {
    func send(message: String)
    func sendAudioMessage(data: Data)
}

class SendBirdChatSession: ChatSession {
    
    private let channel: SBDGroupChannel
    
    init(channel: SBDGroupChannel) {
        self.channel = channel
    }
    
    func send(message: String) {
        channel.sendUserMessage(message) { [weak self] userMessage, error in
            guard let userMessage = userMessage,
                  error == nil else {
                      assertionFailure("Failed to send message to channel with url: \(String(describing: self?.channel.channelUrl))")
                      return
                  }
            
            print("Successfully sent message: \(userMessage.messageId)")
        }
    }
    
    func sendAudioMessage(data: Data) {
        guard let params = SBDFileMessageParams(file: data) else { return }
        
        channel.sendFileMessage(with: params) { [weak self] userMessage, error in
            guard let userMessage = userMessage,
                  error == nil else {
                      assertionFailure("Failed to send message to channel with url: \(String(describing: self?.channel.channelUrl))")
                      return
                  }
            
            print("Successfully sent message: \(userMessage.messageId)")
        }
    }
}
