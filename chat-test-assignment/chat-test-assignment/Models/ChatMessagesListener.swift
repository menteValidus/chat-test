//
//  ChatMessagesListener.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import SendBirdSDK

protocol ChatMessagesListener: AnyObject {
    var lastReceivedMessagePublisher: Published<Message?>.Publisher { get }
}

final class SendBirdChatMessagesListener: NSObject, ChatMessagesListener {
    
    var lastReceivedMessagePublisher: Published<Message?>.Publisher { $lastReceivedMessage }
    
    @Published
    private var lastReceivedMessage: Message?
    
    override init() {
        super.init()
        
        SBDMain.add(self as SBDChannelDelegate, identifier: UUID().uuidString)
    }
    
    deinit {
        print("Deinited")
    }
}

extension SendBirdChatMessagesListener: SBDChannelDelegate {
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        let date = Date(timeIntervalSince1970: TimeInterval(message.createdAt))
        
        if let fileMessage = message as? SBDFileMessage,
           let url = URL(string: fileMessage.url) {
            DownloadManager.downloadFile(fromUrl: url) { [weak self] data in
                let path = FileManager.default.urls(for: .documentDirectory,
                                                       in: .userDomainMask)[0].appendingPathComponent("\(UUID().uuidString).m4a")
                
                try? data.write(to: path)
                
                self?.lastReceivedMessage = Message(date: date,
                                                    audioAssetUrl: path)
            }
        } else {
            lastReceivedMessage = Message(text: message.message,
                                          date: date)
        }
    }
}

import Combine

final class DownloadManager {
    
    static func downloadFile(fromUrl url: URL, _ completionHandler: @escaping (Data) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Failed to download data from \(url), error: \(error)")
                    return
                }
            
                if let data = data {
                    completionHandler(data)
                }
            }
            task.resume()
    }
}
