//
//  ChatMessagesListener.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import SendBirdSDK
import Combine

protocol ChatMessagesListener: AnyObject {
    var lastReceivedMessagePublisher: Published<Message?>.Publisher { get }
}

final class SendBirdChatMessagesListener: NSObject, ChatMessagesListener {
    
    var lastReceivedMessagePublisher: Published<Message?>.Publisher { $lastReceivedMessage }
    
    @Published
    private var lastReceivedMessage: Message?
    
    private var flowHandler: SaveFileFromUrlFlowHandler?
    
    private var cancelBag: Set<AnyCancellable> = []
    
    override init() {
        super.init()
        
        SBDMain.add(self as SBDChannelDelegate, identifier: UUID().uuidString)
    }
}

extension SendBirdChatMessagesListener: SBDChannelDelegate {
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if let fileMessage = message as? SBDFileMessage {
            save(audioMessage: fileMessage)
        } else {
            save(textMessage: message)
        }
    }
    
    private func save(audioMessage message: SBDFileMessage) {
        guard let url = URL(string: message.url) else { return }
        
        flowHandler = SaveFileFromUrlFlowHandler()
        flowHandler?.process(remoteFileUrl: url)
            .sink { result in
                switch result {
                case .failure(let error):
                    print(error)
                default:
                    return
                }
            } receiveValue: { [weak self] url in
                let date = Date(timeIntervalSince1970: TimeInterval(message.createdAt))
                self?.lastReceivedMessage = Message(date: date,
                                                    audioAssetUrl: url)
            }
            .store(in: &cancelBag)
    }
    
    private func save(textMessage message: SBDBaseMessage) {
        let date = Date(timeIntervalSince1970: TimeInterval(message.createdAt))
        lastReceivedMessage = Message(text: message.message,
                                      date: date)
    }
}
