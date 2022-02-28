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

final class SendBirdChatService: ChatService {
    
    private let storage: UnsecureStorage
    
    init() {
        storage = UserDefaultsStorage()
    }
    
    func enterChannel(invitationId: String,
                      _ completionHandler: @escaping (ChatSession) -> Void) {
        SBDGroupChannel.createChannel(withUserIds: [invitationId],
                                      isDistinct: false) { groupChannel, error in
            guard let channel = groupChannel,
                  error == nil else {
                      assertionFailure("Failed to open channel with params for user id")
                      return
                  }
            
            print("Successfully created channel with url: \(channel.channelUrl)")
            
            completionHandler(SendBirdChatSession(channel: channel))
        }
    }
}
