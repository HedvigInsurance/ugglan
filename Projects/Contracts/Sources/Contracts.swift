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

public struct Contracts {
    public static var openFreeTextChatHandler: (_ viewController: UIViewController) -> Void = { _ in }
    public init() {}
}

extension Contracts: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.InsurancesTab.title
        viewController.installChatButton()

        let bag = DisposeBag()

        bag += viewController.install(ContractTable(presentingViewController: viewController))

        return (viewController, bag)
    }
}

extension Contracts: Tabable {
    public func tabBarItem() -> UITabBarItem {
        UITabBarItem(
            title: L10n.InsurancesTab.title,
            image: Asset.tab.image,
            selectedImage: Asset.tabActive.image
        )
    }
}
