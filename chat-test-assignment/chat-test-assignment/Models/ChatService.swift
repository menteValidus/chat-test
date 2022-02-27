//
//  ChatService.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import SendBirdSDK
import UIKit

protocol ChatService: AnyObject {
    func enterChannel(invitationId: String, _ completionHandler: @escaping (ChatSession) -> Void)
}

// TODO: Fix this mess
final class SendBirdChatService: ChatService {
    
    private let storage: UnsecureStorage
    
    init() {
        storage = UserDefaultsStorage()
    }
    
    func enterChannel(invitationId: String,
                      _ completionHandler: @escaping (ChatSession) -> Void) {
        let params = SBDOpenChannelParams()
        params.name = "Test_channel"
        
        SBDGroupChannel.createChannel(withUserIds: [invitationId],
                                      isDistinct: false) { groupChannel, error in
            guard let channel = groupChannel,
                  error == nil else {
                      assertionFailure("Failed to open channel with params: \(params)")
                      return
                  }
            
            print("Successfully created channel with url: \(channel.channelUrl)")
            
            completionHandler(SendBirdChatSession(channel: channel))
        }
    }
}

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
