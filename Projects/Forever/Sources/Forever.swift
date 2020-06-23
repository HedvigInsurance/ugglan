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
    let service: ForeverService

    public init(service: ForeverService) {
        self.service = service
    }
}

extension Forever: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.referralsScreenTitle
        viewController.extendedLayoutIncludesOpaqueBars = true
        let bag = DisposeBag()
        
        let infoBarButton = UIBarButtonItem(image: hCoreUIAssets.info.image, style: .plain, target: nil, action: nil)
        
        bag += infoBarButton.onValue {
            viewController.present(InfoAndTerms(), style: .modal)
        }
        
        viewController.navigationItem.rightBarButtonItem = infoBarButton

        let tableKit = TableKit<String, InvitationRow>(holdIn: bag)
        bag += tableKit.delegate.heightForCell.set { index -> CGFloat in
            tableKit.table[index].cellHeight
        }

        bag += tableKit.view.addTableHeaderView(Header(
            grossAmountSignal: service.dataSignal.map { $0?.grossAmount },
            netAmountSignal: service.dataSignal.map { $0?.netAmount },
            discountCodeSignal: service.dataSignal.map { $0?.discountCode },
            potentialDiscountAmountSignal: service.dataSignal.map { $0?.potentialDiscountAmount }
        ), animated: false)

        bag += viewController.install(tableKit)

        bag += service.dataSignal.atOnce().compactMap { $0?.invitations }.onValue { invitations in
            var table = Table(
                sections: [
                    (
                        L10n.ReferralsActive.Invited.title,
                        invitations.map { InvitationRow(invitation: $0) }
                    ),
                ]
            )
            table.removeEmptySections()
            tableKit.set(table)
        }

        let shareButton = ShareButton()
        tableKit.view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: shareButton.loadableButton.button.type.value.height, right: 0)
        
        bag += tableKit.view.add(shareButton) { buttonView in
            buttonView.layer.zPosition = 100
            buttonView.snp.makeConstraints { make in
                make.bottom.equalTo(
                    tableKit.view.safeAreaLayoutGuide.snp.bottom
                )
                make.trailing.equalTo(
                    tableKit.view.safeAreaLayoutGuide.snp.trailing
                )
                make.leading.equalTo(
                    tableKit.view.safeAreaLayoutGuide.snp.leading
                )
            }
        }.onValue { buttonView in
            shareButton.loadableButton.startLoading()
            viewController.presentConditionally(PushNotificationReminder(), style: .modal).onResult { _ in
                let activity = ActivityView(
                    activityItems: [URL(string: "https://www.hedvig.com/referrals/\(self.service.dataSignal.value?.discountCode ?? "")?utm_source=ios") ?? ""],
                    applicationActivities: nil,
                    sourceView: buttonView,
                    sourceRect: nil
                )
                viewController.present(activity)
                shareButton.loadableButton.stopLoading()
            }
        }

        return (viewController, bag)
    }
}
