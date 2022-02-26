//
//  InviteMeViewController.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 26.02.2022.
//

import UIKit
import SnapKit
import Combine

class InviteMeViewController: UIViewController {
    
    var viewModel: InviteMeViewModel = .init()
    
    private lazy var qrView: UIImageView = .init()
    
    private var cancelBag: Set<AnyCancellable> = []

    // MARK: - Lifecycle
    
    deinit {
        cancelBag.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    private func bindViewModel() {
        viewModel.$invitationQRImage
            .receive(on: RunLoop.main)
            .sink { [weak self] image in
                self?.qrView.image = image
            }
            .store(in: &cancelBag)
    }
}
