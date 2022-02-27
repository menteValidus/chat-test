//
//  ChatViewModel.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import Combine

final class ChatViewModel {
    
    @Published
    private(set) var messages: [Message] = []
    
    private let chatService: ChatService
    private let chatMessagesListener: ChatMessagesListener
    private let invitationId: String
    
    private var chatSession: ChatSession?
    
    private var cancelBag: Set<AnyCancellable> = []
    
    init(chatService: ChatService = SendBirdChatService(),
         invitationId: String = "") {
        self.chatService = chatService
        self.chatMessagesListener = SendBirdChatMessagesListener()
        self.invitationId = invitationId
        
        listenForMessagesUpdate()
    }
    
    init(chatService: ChatService = SendBirdChatService(),
         chatSession: ChatSession) {
        self.chatService = chatService
        self.chatSession = chatSession
        self.chatMessagesListener = SendBirdChatMessagesListener()
        self.invitationId = ""
        
        listenForMessagesUpdate()
    }
    
    func startChat() {
        guard chatSession == nil else {
            print("Chat session already started")
            return
        }
        
        chatService.enterChannel(invitationId: invitationId) { [weak self] chatSession in
            self?.chatSession = chatSession
        }
    }
    
    func send(message: String) {
        chatSession?.send(message: message)
        append(newMessageText: message)
    }
    
    private func append(newMessageText text: String) {
        messages.append(Message(text: text))
    }
    
    private func listenForMessagesUpdate() {
        chatMessagesListener.lastReceivedMessagePublisher
            .dropFirst()
            .sink { [weak self] message in
                self?.append(newMessageText: message ?? "Corrupted message")
            }
            .store(in: &cancelBag)
    }
}
