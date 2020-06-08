//
//  Forever.swift
//  Forever
//
//  Created by sam on 2.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

public struct Forever {
    public init() {}
}

extension Forever: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.referralsScreenTitle
        let bag = DisposeBag()

        let tableKit = TableKit<EmptySection, InvitationRow>.init(holdIn: bag)
        
        bag += tableKit.view.addTableHeaderView(Header(
            grossAmountSignal: .init(100.0),
            netAmountSignal: .init(100.0),
            potentialDiscountAmountSignal: .init(10.0)
        ))

        bag += viewController.install(tableKit)

        tableKit.set(Table(rows: Array(repeating: .init(title: "test"), count: 300)))

        return (viewController, bag)
    }
}
