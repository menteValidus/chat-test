//
//  KeyboardListener.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import Combine
import UIKit

final class KeyboardListener: ObservableObject {
    
    @Published private(set) var keyboardHeight: CGFloat = 0

    private var cancelBag: Set<AnyCancellable> = []

    init() {
        let changePublisher = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification).share()
        let hidePublisher = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).share()

        let heightShowPublisher = changePublisher
            .map { notification -> CGFloat in
                guard let frameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                    return 0
                }

                return frameValue.cgRectValue.height
            }

        let heightHidePublisher = hidePublisher.flatMap { _ in Just(CGFloat(0)) }

        heightShowPublisher
            .merge(with: heightHidePublisher)
            .receive(on: DispatchQueue.main)
            .assign(to: \.keyboardHeight, on: self)
            .store(in: &cancelBag)
    }
}
