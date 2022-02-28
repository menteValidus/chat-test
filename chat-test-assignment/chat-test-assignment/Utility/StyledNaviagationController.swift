//
//  StyledNaviagationController.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 28.02.2022.
//

import UIKit

class StyledNaviagationController: UINavigationController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
    override var shouldAutorotate: Bool {
        false
    }
}
