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
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension Dashboard: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()

        bag += client.watch(
            query: DashboardQuery()
        ).compactMap { $0.data?.member.firstName }.map {
            String(key: .DASHBOARD_BANNER_ACTIVE_TITLE(firstName: $0))
        }.bindTo(viewController, \.navigationItem.title)

        let form = FormView()

        let paymentNeedsSetupSection = PaymentNeedsSetupSection(presentingViewController: viewController)
        bag += form.append(paymentNeedsSetupSection)

        let pendingInsurance = PendingInsurance()
        bag += form.append(pendingInsurance)
        
        let chatPreview = ChatPreview()
        bag += form.append(chatPreview)

        let chatActionsSection = ChatActionsSection(presentingViewController: viewController)
        bag += form.append(chatActionsSection)

        bag += form.append(Spacing(height: 35))

        let myProtectionSection = MyProtectionSection(presentingViewController: viewController)
        bag += form.append(myProtectionSection)

        bag += viewController.install(form)

        let dashboardInsuranceQuery = client.watch(query: DashboardQuery()).compactMap { $0.data?.insurance }
        bag += dashboardInsuranceQuery.bindTo(pendingInsurance.dataSignal)
        bag += dashboardInsuranceQuery.bindTo(myProtectionSection.dataSignal)

        bag += client.fetch(query: ChatActionsQuery())
            .valueSignal
            .compactMap { $0.data?.chatActions }
            .bindTo(chatActionsSection.dataSignal)

        bag += client.watch(query: MyPaymentQuery())
            .compactMap { $0.data }
            .bindTo(paymentNeedsSetupSection.dataSignal)

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
