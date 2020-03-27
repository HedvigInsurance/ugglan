//
//  Dashboard.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-16.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct Dashboard {
    @Inject var client: ApolloClient
    @Inject var remoteConfig: RemoteConfigContainer
}

extension Dashboard: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String(key: .DASHBOARD_SCREEN_TITLE)
        viewController.installChatButton()

        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.spacing = 15
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.edgeInsets = UIEdgeInsets(horizontalInset: 0, verticalInset: 15)

        let importantMessagesSection = ImportantMessagesSection(presentingViewController: viewController)
        bag += containerStackView.addArranged(importantMessagesSection)

        let pendingInsurance = PendingInsurance()
        bag += containerStackView.addArranged(pendingInsurance)

        bag += viewController.install(containerStackView)

        let dataBag = bag.innerBag()

        func fetch() {
            dataBag.dispose()

            let dashboardInsuranceQuery = client
                .watch(query: DashboardQuery())
                .loader(after: 2, view: viewController.view)
                .compactMap { $0.data?.insurance }

            dataBag += dashboardInsuranceQuery.bindTo(pendingInsurance.dataSignal)
        }

        fetch()

        bag += NotificationCenter.default.signal(forName: .localeSwitched).onValue { _ in
            fetch()
        }

        return (viewController, bag)
    }
}

extension Dashboard: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: String(key: .TAB_DASHBOARD_TITLE),
            image: Asset.dashboardTab.image,
            selectedImage: nil
        )
    }
}
