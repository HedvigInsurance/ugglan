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

        let tableKit = TableKit<String, InvitationRow>.init(holdIn: bag)
        bag += tableKit.delegate.heightForCell.set { index -> CGFloat in
            return InvitationRow.cellHeight
        }
        
        bag += tableKit.view.addTableHeaderView(Header(
            grossAmountSignal: .init(.sek(100)),
            netAmountSignal: .init(.sek(100)),
            potentialDiscountAmountSignal: .init(.sek(10))
        ))

        bag += viewController.install(tableKit)

        tableKit.table = Table.init(sections: [(L10n.ReferralsActive.Invited.title, [
            .init(name: "Torsten", state: .active, discount: .sek(-10)),
            .init(name: "Fisken", state: .pending, discount: .sek(-10)),
            .init(name: "Någon annan", state: .terminated, discount: .sek(-10))
        ])])
        
        let button = Button(title: "Share code", type: .standard(backgroundColor: .brand(.primaryButtonBackgroundColor), textColor: .brand(.primaryButtonTextColor)))
        tableKit.view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: button.type.value.height, right: 0)
                
        bag += tableKit.view.add(button) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.bottom.equalTo(
                    tableKit.view.safeAreaLayoutGuide.snp.bottom
                ).inset(20)
                make.width.equalToSuperview().inset(15)
                make.centerX.equalToSuperview()
                make.height.equalTo(button.type.value.height)
            }
        }

        return (viewController, bag)
    }
}
