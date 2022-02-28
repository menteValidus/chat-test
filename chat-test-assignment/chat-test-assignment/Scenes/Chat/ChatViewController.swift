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
    
    private lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
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
        
        viewModel.$isRecording
            .receive(on: RunLoop.main)
            .sink { [weak self] isRecording in
                let configuration = UIImage.SymbolConfiguration(pointSize: 20)
                let image = isRecording
                            ? UIImage(systemName: "stop.circle", withConfiguration: configuration)
                            : UIImage(systemName: "record.circle", withConfiguration: configuration)
                self?.recordButton.setImage(image, for: .normal)
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
        
        textfield.snp.makeConstraints { make in
            enterMessageBottomConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-bottomOffset).constraint
            make.leading.equalTo(self.view.snp.leading).offset(30)
        }
        
        self.view.addSubview(recordButton)
        
        recordButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.textfield.snp.centerY)
            make.trailing.equalTo(self.textfield.snp.trailing).offset(8)
            make.trailing.equalTo(self.view.snp.trailing).offset(-30)
        }
        
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.top)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.bottom.equalTo(self.textfield.snp.top).offset(-24)
        }
    }
    
    private func registerCells() {
        tableView.register(MessageTableViewCell.self,
                           forCellReuseIdentifier: MessageTableViewCell.reuseIdentifier)
        tableView.register(AudioMessageTableViewCell.self,
                           forCellReuseIdentifier: AudioMessageTableViewCell.reuseIdentifier)
    }
    
    // MARK: - Actions
    
    @objc
    private func recordButtonTapped() {
        viewModel.recordingActionCalled()
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
        let message = viewModel.messages[indexPath.row]
        
        if message.audioAssetUrl != nil {
            return createAudioMessageCellView(forTableView: tableView, withMessageData: message)
        } else {
            return createTextMessageCellView(forTableView: tableView, withMessageData: message)
        }
    }
    
    private func createTextMessageCellView(forTableView tableView: UITableView,
                                           withMessageData message: Message) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.reuseIdentifier) as? MessageTableViewCell else {
            return .init()
        }
        cell.selectionStyle = .none
        cell.messageText = message.text
        
        return cell
    }
    
    private func createAudioMessageCellView(forTableView tableView: UITableView,
                                            withMessageData message: Message) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AudioMessageTableViewCell.reuseIdentifier) as? AudioMessageTableViewCell,
              let audioUrl = message.audioAssetUrl else {
            return .init()
        }
        cell.selectionStyle = .none
        cell.onTapAction = { [weak self] in
            self?.viewModel.playAudioMessage(forUrl: audioUrl)
        }
        
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
