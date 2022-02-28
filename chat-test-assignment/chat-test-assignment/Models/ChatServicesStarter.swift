//
//  ChatServicesStarter.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import SendBirdSDK

protocol ServicesStarter: AnyObject {
    func start()
}

final class ChatServicesStarter: ServicesStarter {
    
    private let storage: UnsecureStorage
    
    private let appId = "0A4C4F2E-DDD7-45A0-8BBF-CDFFDFB899C7"
    
    init(unsecureStorage: UnsecureStorage = UserDefaultsStorage()) {
        self.storage = unsecureStorage
    }
    
    func start() {
        SBDMain.initWithApplicationId(appId)
        
        handleUserChatConnection()
    }
    
    private func handleUserChatConnection() {
        if let userId: String = storage.get(forKey: .userId) {
            connectToChatService(withId: userId)
        } else {
            let userId = createAndSaveNewUserId()
            connectToChatService(withId: userId)
        }
    }
    
    private func connectToChatService(withId userId: String) {
        SBDMain.connect(withUserId: userId) { user, error in
            guard let user = user,
                  error == nil else {
                      assertionFailure("Failed to connect user with ID: \(userId)\nError: ]\(String(describing: error))")
                      return
                  }
            
            print("Successfully connected with user id: \(userId)\nUser info: \(user)")
        }
    }
    
    private func createAndSaveNewUserId() -> String {
        let id = UUID().uuidString
        try? storage.set(id, forKey: .userId)
        
        return id
    }
}
