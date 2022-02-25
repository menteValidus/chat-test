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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }

    private func configureViews() {
        self.view.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { [self] make in
            make.center.equalTo(self.view.center)
        }
    }
}

