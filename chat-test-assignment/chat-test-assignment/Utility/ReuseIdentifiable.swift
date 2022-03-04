//
//  ReuseIdentifiable.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 26.02.2022.
//

public protocol ReuseIdentifiable {
    static var reuseIdentifier: String { get }
}

public extension ReuseIdentifiable {
    static var reuseIdentifier: String {
        String(describing: self) + "ReuseIdentifier"
    }
}
