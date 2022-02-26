//
//  SceneDelegate.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 25.02.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let viewController = InviteMeViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        ChatServicesStarter().start()
    }

}

