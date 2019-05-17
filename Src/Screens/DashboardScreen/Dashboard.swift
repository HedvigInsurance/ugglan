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
    let remoteConfig: RemoteConfigContainer

    init(client: ApolloClient = ApolloContainer.shared.client, remoteConfig: RemoteConfigContainer = RemoteConfigContainer.shared) {
        self.client = client
        self.remoteConfig = remoteConfig
    }
}

var dashboardOpenFreeTextChat: (_ presentingViewController: UIViewController) -> Void = { presentingViewController in
    let chatOverlay = DraggableOverlay(presentable: FreeTextChat())
    presentingViewController.present(chatOverlay, style: .default, options: [.prefersNavigationBarHidden(false)])
}

extension Dashboard: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String(key: .DASHBOARD_SCREEN_TITLE)
        viewController.installChatButton()

        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.spacing = 25
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.edgeInsets = UIEdgeInsets(horizontalInset: 0, verticalInset: 25)

        let chatPreview = ChatPreview(presentingViewController: viewController)
        bag += containerStackView.addArranged(chatPreview)

        let paymentNeedsSetupSection = PaymentNeedsSetupSection(presentingViewController: viewController)
        bag += containerStackView.addArranged(paymentNeedsSetupSection)

        let pendingInsurance = PendingInsurance()
        bag += containerStackView.addArranged(pendingInsurance)

        let myProtectionSection = MyProtectionSection(presentingViewController: viewController)
        bag += containerStackView.addArranged(myProtectionSection)

        bag += viewController.install(containerStackView)

        let dashboardInsuranceQuery = client
            .watch(query: DashboardQuery())
            .loader(after: 2, view: viewController.view)
            .compactMap { $0.data?.insurance }

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
