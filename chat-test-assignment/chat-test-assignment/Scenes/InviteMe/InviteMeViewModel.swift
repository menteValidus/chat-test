//
//  InviteMeViewModel.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 26.02.2022.
//

import UIKit

final class InviteMeViewModel {
    
    @Published
    private(set) var invitationQRImage: UIImage?
    
    private let storage: UnsecureStorage
    
    init(unsecureStorage: UnsecureStorage = UserDefaultsStorage()) {
        self.storage = unsecureStorage
    }
    
    func createInvitationQRCode() {
        guard let userId: String = storage.get(forKey: .userId) else {
            print("Failed to retreive user id, key used: \(StorageKey.userId.rawValue)")
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let qrImage = QRCodeGenerator.generateQRCode(from: userId) else {
                print("Failed to create qr code for string: \(userId)")
                return
            }
            
            self?.invitationQRImage = qrImage
        }
    }
    
    func isUserId(_ id: String) -> Bool {
        id != storage.get(forKey: .userId)
    }
}
