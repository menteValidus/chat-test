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
    @Published
    private(set) var isRecording: Bool = false
    
    private let chatService: ChatService
    private let chatMessagesListener: ChatMessagesListener
    private let audioRecorderService: AudioRecorderService
    private let audioPlayerService: AudioPlayerService
    private let invitationId: String
    
    private var chatSession: ChatSession?
    
    private var cancelBag: Set<AnyCancellable> = []
    
    init(chatService: ChatService = SendBirdChatService(),
         audioRecorderService: AudioRecorderService = AudioSessionRecorderService(),
         audioPlayerService: AudioPlayerService = AudioPlayerService(),
         invitationId: String = "") {
        self.chatService = chatService
        self.chatMessagesListener = SendBirdChatMessagesListener()
        self.audioRecorderService = audioRecorderService
        self.audioPlayerService = audioPlayerService
        self.invitationId = invitationId
        
        listenForMessagesUpdate()
    }
    
    init(chatService: ChatService = SendBirdChatService(),
         audioRecorderService: AudioRecorderService = AudioSessionRecorderService(),
         audioPlayerService: AudioPlayerService = AudioPlayerService(),
         chatSession: ChatSession) {
        self.chatService = chatService
        self.chatSession = chatSession
        self.chatMessagesListener = SendBirdChatMessagesListener()
        self.audioRecorderService = audioRecorderService
        self.audioPlayerService = audioPlayerService
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
    
    func recordingActionCalled() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        isRecording = true
        try? audioRecorderService.record()
    }
    
    private func stopRecording() {
        isRecording = false
        audioRecorderService.stopRecording()
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
        
        audioRecorderService.lastRecordedAudioURLPublisher
            .dropFirst()
            .sink { [weak self] audioUrl in
                self?.append(newMessageText: "Audio message")
                
                guard let audioUrl = audioUrl else { return }
                try? self?.audioPlayerService.playSound(forURL: audioUrl)
            }
            .store(in: &cancelBag)
    }
}
