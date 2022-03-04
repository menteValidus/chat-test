//
//  Message.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 26.02.2022.
//

import Foundation

struct Message {
    var text: String
    var date: Date
    var audioAssetUrl: URL?
    var createdByUser: Bool
    
    init(text: String = "",
         date: Date = Date(),
         audioAssetUrl: URL? = nil,
         createdByUser: Bool = false) {
        self.text = text
        self.date = date
        self.audioAssetUrl = audioAssetUrl
        self.createdByUser = createdByUser
    }
}
