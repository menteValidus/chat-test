//
//  ChatViewModel.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import Combine

final class ChatViewModel {
    
    @Published
    private(set) var lastReceivedMessage: String?
    
    @Published
    private(set) var messages: [Message] = [.init(text: "Testing...\nTesting..."),
                                            .init(text: "Another test...\n\n\n\n\n\nEnd of line..."),
                                            .init(text: "Another test...\n\n\n\n\n\nEnd of line...")]
    
    private let chatService: ChatService
    private let chatMessagesListener: ChatMessagesListener
    
    private var chatSession: ChatSession?
    
    private var cancelBag: Set<AnyCancellable> = []
    
    init(chatService: ChatService = SendBirdChatService()) {
        self.chatService = chatService
        self.chatMessagesListener = SendBirdChatMessagesListener()
        
        chatMessagesListener.lastReceivedMessagePublisher
            .sink { [weak self] message in
                self?.lastReceivedMessage = message
            }
            .store(in: &cancelBag)
    }
    
    func startChat() {
        guard chatSession == nil else {
            print("Chat session already started")
            return
        }
        
        chatService.enterChannel { [weak self] chatSession in
            self?.chatSession = chatSession
        }
    }
    
    func send(message: String) {
        chatSession?.send(message: message)
    }
}
