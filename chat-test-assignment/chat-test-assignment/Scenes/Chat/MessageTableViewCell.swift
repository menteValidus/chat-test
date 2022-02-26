//
//  MessageTableViewCell.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 26.02.2022.
//

import UIKit
import SnapKit

final class MessageTableViewCell: UITableViewCell, ReuseIdentifiable {
    
    var messageText: String? {
        didSet {
            messageView.messageText = messageText
        }
    }
    
    private lazy var messageView: MessageBubbleView = {
        .init()
    }()
    
    init() {
        super.init(style: .default, reuseIdentifier: Self.reuseIdentifier)
        commonInit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(messageView)
        
        messageView.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading).offset(24)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.top.equalTo(self.snp.top).offset(8)
            make.bottom.equalTo(self.snp.bottom).offset(-8)
        }
    }
}
