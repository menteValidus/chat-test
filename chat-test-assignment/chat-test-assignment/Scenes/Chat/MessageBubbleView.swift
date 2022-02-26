//
//  MessageBubbleView.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 26.02.2022.
//

import UIKit

final class MessageBubbleView: UIView {
    
    private lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.text = "Testing out, testing out..."
        
        return textView
    }()
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .green
        layer.cornerRadius = 10
        
        addSubview(messageTextView)
        
        messageTextView.snp.makeConstraints { make in
            make.edges.equalTo(self.snp.edges)
        }
    }
}
