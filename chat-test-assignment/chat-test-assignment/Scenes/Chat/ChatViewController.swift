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
    
    private let bottomOffset: CGFloat = 30
    
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    deinit {
        cancelBag.removeAll()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        registerCells()
        subscribeToKeyboardChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bindViewModel()
        viewModel.startChat()
    }
    
    // MARK: - Configuration
    
    private func bindViewModel() {
        viewModel.$messages
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancelBag)
    }
    
    private func subscribeToKeyboardChanges() {
        keyboardListener.$keyboardHeight
            .receive(on: RunLoop.main)
            .sink { [weak self] height in
                let offset = height > 0 ? height : self?.bottomOffset ?? 0
                self?.enterMessageBottomConstraint?.update(offset: -offset)
            }
            .store(in: &cancelBag)
    }

    private func configureViews() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(textfield)
        
        textfield.snp.makeConstraints { [self] make in
            enterMessageBottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-bottomOffset).constraint
            make.leading.equalTo(self.view.snp.leading).offset(30)
            make.trailing.equalTo(self.view.snp.trailing).offset(-30)
        }
        
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { [self] make in
            make.top.equalTo(self.view.snp.top)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.bottom.equalTo(self.textfield.snp.top).offset(-24)
        }
        
        tableView.backgroundColor = .red
    }
    
    private func registerCells() {
        tableView.register(MessageTableViewCell.self,
                           forCellReuseIdentifier: MessageTableViewCell.reuseIdentifier)
    }
}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.reuseIdentifier) as? MessageTableViewCell else {
            return .init()
        }
        cell.messageText = viewModel.messages[indexPath.row].text
        
        return cell
    }
}

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let messageText = textField.text else {
            return false
        }
        
        viewModel.send(message: messageText)
        textField.text = nil
        return true
    }
}
