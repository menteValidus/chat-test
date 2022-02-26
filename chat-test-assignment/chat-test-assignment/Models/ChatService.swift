//
//  ChatService.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import SendBirdSDK
import UIKit

protocol ChatService: AnyObject {
    func enterChannel(_ completionHandler: @escaping (ChatSession) -> Void)
}

// TODO: Fix this mess
final class SendBirdChatService: ChatService {
    
    private let storage: UnsecureStorage
    
    init() {
        storage = UserDefaultsStorage()
    }
    
    func enterChannel(_ completionHandler: @escaping (ChatSession) -> Void) {
        let params = SBDOpenChannelParams()
        params.name = "Test_channel"
        
//        if let channelUrl: String = storage.get(forKey: .lastChannelId) {
//            SBDOpenChannel.getWithUrl(channelUrl) { openChannel, error in
//                guard let channel = openChannel,
//                      error == nil else {
//                          assertionFailure("Failed to enter channel with url: \(channelUrl)")
//                          return
//                      }
//
//                print("Successfully entered channel with url: \(channel.channelUrl)")
//
//                channel.enter { error in
//                    guard error == nil else {
//                        assertionFailure("Failed to enter channel with url: \(channel.channelUrl)")
//                        return
//                    }
//
//                    completionHandler(SendBirdChatSession(openChannel: channel))
//                }
//            }
//
//            return
//        }
        
        SBDGroupChannel.createChannel(withUserIds: ["6AC5DF5A-EEB0-47AF-860F-046A7855DCBE"],
                                      isDistinct: false) { openChannel, error in
            guard let channel = openChannel,
                  error == nil else {
                      assertionFailure("Failed to open channel with params: \(params)")
                      return
                  }
            
            print("Successfully created channel with url: \(channel.channelUrl)")
            
            SBDOpenChannel.getWithUrl(channel.channelUrl) { openChannel, error in
                guard let channel = openChannel,
                      error == nil else {
                          assertionFailure("Failed to enter channel with url: \(channel.channelUrl)")
                          return
                      }
                
                print("Successfully entered channel with url: \(channel.channelUrl)")
                
                channel.enter { [weak self] error in
                    guard error == nil else {
                        assertionFailure("Failed to enter channel with url: \(channel.channelUrl)")
                        return
                    }
                    
                    try? self?.storage.set(channel.channelUrl, forKey: .lastChannelId)
                    completionHandler(SendBirdChatSession(openChannel: channel))
                }
            }
        }
    }
}

protocol ChatSession: AnyObject {
    func send(message: String)
}

class SendBirdChatSession: ChatSession {
    
    private let channel: SBDOpenChannel
    
    init(openChannel: SBDOpenChannel) {
        channel = openChannel
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
}
