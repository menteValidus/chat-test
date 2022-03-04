//
//  ChatViewModel.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import Foundation
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
        appendUser(newMessageText: message)
    }
    
    private func sendUserAudioMessage(audioUrl: URL) {
        guard let audioData = try? Data(contentsOf: audioUrl) else { return }
        
        chatSession?.sendAudioMessage(data: audioData)
        appendnewAudioMessage(audioMessageUrl: audioUrl,
                              createdByUser: true)
    }
    
    func recordingActionCalled() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func playAudioMessage(forUrl url: URL) {
        try? audioPlayerService.playSound(forURL: url)
    }
    
    private func startRecording() {
        isRecording = true
        try? audioRecorderService.record()
    }
    
    private func stopRecording() {
        isRecording = false
        audioRecorderService.stopRecording()
    }
    
    private func append(newMessage message: Message) {
        messages.append(message)
    }
    
    private func appendUser(newMessageText text: String) {
        messages.append(Message(text: text,
                                createdByUser: true))
    }
    
    private func appendnewAudioMessage(audioMessageUrl url: URL,
                                       createdByUser: Bool = false) {
        messages.append(Message(audioAssetUrl: url,
                                createdByUser: createdByUser))
    }
    
    private func listenForMessagesUpdate() {
        chatMessagesListener.lastReceivedMessagePublisher
            .dropFirst()
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.append(newMessage: message)
            }
            .store(in: &cancelBag)
        
        audioRecorderService.lastRecordedAudioURLPublisher
            .dropFirst()
            .compactMap { $0 }
            .sink { [weak self] audioUrl in
                self?.sendUserAudioMessage(audioUrl: audioUrl)
            }
            .store(in: &cancelBag)
    }
}
