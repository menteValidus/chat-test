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
    
    init(text: String = "", date: Date = Date()) {
        self.text = text
        self.date = date
    }
}
