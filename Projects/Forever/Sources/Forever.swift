//
//  Forever.swift
//  Forever
//
//  Created by sam on 2.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import hCore
import hCoreUI
import Presentation
import Flow
import Form

public struct Forever {
    public init() {}
}

extension Forever: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.referralsScreenTitle
        let bag = DisposeBag()
        
        let tableKit = TableKit<EmptySection, InvitationRow>.init(holdIn: bag)
        
        bag += viewController.install(tableKit)
        
        tableKit.set(Table(rows: Array.init(repeating: .init(title: "test"), count: 300)))
                
        return (viewController, bag)
    }
}
