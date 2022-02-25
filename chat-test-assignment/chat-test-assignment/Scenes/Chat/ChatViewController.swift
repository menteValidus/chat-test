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
    
    private let keyboardListener = KeyboardListener()
    
    private var cancelBag: Set<AnyCancellable> = []
    
    private var enterMessageBottomConstraint: Constraint?
    
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
        subscribeToKeyboardChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bindViewModel()
        viewModel.startChat()
    }
    
    private func bindViewModel() {
    }
    
    private func subscribeToKeyboardChanges() {
        keyboardListener.$keyboardHeight
            .receive(on: RunLoop.main)
            .sink { [weak self] height in
                self?.enterMessageBottomConstraint?.update(offset: -height)
            }
            .store(in: &cancelBag)
    }

    private func configureViews() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(textfield)
        
        textfield.snp.makeConstraints { [self] make in
            enterMessageBottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).constraint
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
