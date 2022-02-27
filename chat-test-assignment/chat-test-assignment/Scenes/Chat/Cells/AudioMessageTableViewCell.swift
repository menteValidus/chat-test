//
//  AudioMessageTableViewCell.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 27.02.2022.
//

import UIKit
import SnapKit

final class AudioMessageTableViewCell: UITableViewCell, ReuseIdentifiable {
    
    typealias Action = () -> Void
    
    var onTapAction: Action?
    
    private lazy var messageView: MessageBubbleView = {
        let view = MessageBubbleView()
        view.backgroundColor = .systemBlue
        
        return view
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "play.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        return button
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
        
        contentView.addSubview(messageView)
        
        messageView.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView.snp.leading).offset(24)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-24)
            make.top.equalTo(self.contentView.snp.top).offset(8)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-8)
        }
        
        contentView.addSubview(playButton)
        
        playButton.snp.makeConstraints { make in
            // TODO: Specify here top down constraints after making cells elastic
            make.trailing.equalTo(self.messageView.snp.trailing).offset(-30)
            
            make.centerY.equalTo(self.messageView.snp.centerY)
        }
    }
    
    @objc
    private func buttonTapped() {
        onTapAction?()
    }
}

