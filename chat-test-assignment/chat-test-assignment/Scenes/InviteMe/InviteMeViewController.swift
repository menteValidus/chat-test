//
//  InviteMeViewController.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 26.02.2022.
//

import UIKit
import SnapKit
import Combine
import SendBirdSDK

class InviteMeViewController: UIViewController {
    
    var viewModel: InviteMeViewModel = .init()
    
    private lazy var qrView: UIImageView = .init()
    private lazy var scanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan invitation", for: .normal)
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private var cancelBag: Set<AnyCancellable> = []

    // MARK: - Lifecycle
    
    deinit {
        cancelBag.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SBDMain.add(self, identifier: self.description)
        
        configureViews()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.createInvitationQRCode()
    }
    
    // MARK: - Configuration
    
    private func configureViews() {
        view.addSubview(qrView)
        
        qrView.snp.makeConstraints { make in
            make.center.equalTo(self.view.snp.center)
        }
        
        view.addSubview(scanButton)
        
        scanButton.snp.makeConstraints { make in
            make.top.equalTo(qrView.snp.bottom).offset(30)
            make.centerX.equalTo(qrView.snp.centerX)
        }
    }
    
    private func bindViewModel() {
        viewModel.$invitationQRImage
            .receive(on: RunLoop.main)
            .sink { [weak self] image in
                self?.qrView.image = image
            }
            .store(in: &cancelBag)
    }
    
    // MARK: - Actions
    
    @objc
    private func sendButtonTapped() {
        self.navigationController?.pushViewController(InvitationCodeScanViewController(), animated: true)
    }
}

extension InviteMeViewController: SBDChannelDelegate {
    
    func channel(_ sender: SBDGroupChannel, didReceiveInvitation invitees: [SBDUser]?, inviter: SBDUser?) {
        sender.acceptInvitation { error in
            print("Accepting invitation", error)
        }
    }
}
