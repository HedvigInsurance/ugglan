//
//  InvitationScreen.swift
//  Forever
//
//  Created by sam on 1.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Presentation
import Flow

struct InvitationScreen {
    
}

extension InvitationScreen: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        return (viewController, bag)
    }
}
