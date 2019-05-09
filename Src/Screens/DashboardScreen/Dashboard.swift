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
    let chatOverlay = DraggableOverlay(presentable: Chat())
    presentingViewController.present(chatOverlay, style: .default, options: [.prefersNavigationBarHidden(false)])
}

extension Dashboard: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String(key: .DASHBOARD_SCREEN_TITLE)

        let chatButtonView = UIControl()
        chatButtonView.backgroundColor = .offLightGray
        chatButtonView.layer.cornerRadius = 20

        bag += chatButtonView.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.25)) {
            chatButtonView.backgroundColor = UIColor.offLightGray.darkened(amount: 0.05)
        }

        bag += merge(
            chatButtonView.signal(for: .touchUpInside).delay(by: 0.2),
            chatButtonView.signal(for: .touchUpOutside),
            chatButtonView.signal(for: .touchCancel)
        ).animated(style: AnimationStyle.easeOut(duration: 0.25)) {
            chatButtonView.backgroundColor = UIColor.offLightGray
        }

        bag += chatButtonView.signal(for: .touchUpInside).onValue { _ in
            dashboardOpenFreeTextChat(viewController)
        }

        let chatIcon = UIImageView()
        chatIcon.image = Asset.chat.image
        chatIcon.contentMode = .scaleAspectFit

        chatButtonView.addSubview(chatIcon)

        chatIcon.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview().multipliedBy(0.5)
            make.center.equalToSuperview()
        }

        let item = UIBarButtonItem(customView: chatButtonView)

        viewController.navigationItem.rightBarButtonItem = item

        chatButtonView.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(40)
        }

        let form = FormView()
        form.dynamicStyle = .systemPlain

        let paymentNeedsSetupSection = PaymentNeedsSetupSection(presentingViewController: viewController)
        bag += form.append(paymentNeedsSetupSection)

        let pendingInsurance = PendingInsurance()
        bag += form.append(pendingInsurance)
        
        if self.remoteConfig.chatPreviewEnabled() {
            let chatPreview = ChatPreview(presentingViewController: viewController)
            bag += form.append(chatPreview)
        }

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
