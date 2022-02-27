//
//  MessageBubbleView.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 26.02.2022.
//

import UIKit

final class MessageBubbleView: UIView {
    
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
        backgroundColor = .systemGreen
        layer.cornerRadius = 10
    }
}
