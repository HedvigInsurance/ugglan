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
        viewController.title = String(key: .DASHBOARD_SCREEN_TITLE)

        let form = FormView()

        let paymentNeedsSetupSection = PaymentNeedsSetupSection(presentingViewController: viewController)
        bag += form.append(paymentNeedsSetupSection)

        let pendingInsurance = PendingInsurance()
        bag += form.append(pendingInsurance)
        
        let chatPreview = ChatPreview()
        bag += form.append(chatPreview)

        bag += form.append(Spacing(height: 35))

        let myProtectionSection = MyProtectionSection(presentingViewController: viewController)
        bag += form.append(myProtectionSection)

        bag += viewController.install(form)

        let dashboardInsuranceQuery = client.watch(query: DashboardQuery()).compactMap { $0.data?.insurance }
        bag += dashboardInsuranceQuery.bindTo(pendingInsurance.dataSignal)
        bag += dashboardInsuranceQuery.bindTo(myProtectionSection.dataSignal)

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
