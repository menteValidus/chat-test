//
//  UserDefaultsStorage.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import Foundation

enum StorageKey: String {
    case userId
}

protocol KeyValueStorage {
    func set<Value>(_ value: Value, forKey key: StorageKey) throws
    func get<Value>(forKey key: StorageKey) -> Value?

    func deleteValue(forKey key: StorageKey) throws
}

protocol UnsecureStorage: KeyValueStorage {
    typealias Entry = (key: String, value: Any)
}


final class UserDefaultsStorage: UnsecureStorage {
    let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func set<Value>(_ value: Value, forKey key: StorageKey) throws {
        userDefaults.set(value, forKey: key.rawValue)
    }

    public func get<Value>(forKey key: StorageKey) -> Value? {
        userDefaults.value(forKey: key.rawValue) as? Value
    }

    public func deleteValue(forKey key: StorageKey) throws {
        userDefaults.removeObject(forKey: key.rawValue)
    }
}
