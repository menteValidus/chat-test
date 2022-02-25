//
//  ChatViewController.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import UIKit
import SnapKit
import Combine

class ChatViewController: UIViewController {
    
    var viewModel: ChatViewModel = .init()
    
    private var cancelBag: Set<AnyCancellable> = []
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Waiting for the message..."
        
        return label
    }()
    
    private lazy var textfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Send a message..."
        textfield.delegate = self
        
        return textfield
    }()
    
    deinit {
        cancelBag.removeAll()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bindViewModel()
        viewModel.startChat()
    }
    
    private func bindViewModel() {
        viewModel.$lastReceivedMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                self?.messageLabel.text = message ?? "Waiting for the message..."
            }
            .store(in: &cancelBag)
    }

    private func configureViews() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { [self] make in
            make.center.equalTo(self.view.center)
        }
        
        self.view.addSubview(textfield)
        
        textfield.snp.makeConstraints { [self] make in
            make.top.equalTo(messageLabel.snp.bottom).offset(12)
            make.leading.equalTo(self.view.snp.leading).offset(30)
            make.trailing.equalTo(self.view.snp.trailing).offset(-30)
        }
    }
}

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let messageText = textField.text else {
            return false
        }
        
        viewModel.send(message: messageText)
        return true
    }
}
