//
//  Contracts.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-16.
//

import Flow
import Foundation
import hCore
import Presentation
import UIKit

struct Contracts {}

extension Contracts: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.dashboardScreenTitle
        viewController.installChatButton()

        let bag = DisposeBag()

        bag += viewController.install(ContractTable(presentingViewController: viewController))

        return (viewController, bag)
    }
}

extension Contracts: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: L10n.tabDashboardTitle,
            image: Asset.dashboardTab.image,
            selectedImage: nil
        )
    }
}
