//
//  ViewController.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Waiting for the message..."
        
        return label
    }()
    
    private lazy var textfield: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Send a message..."
        
        return textfield
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }

    private func configureViews() {
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

