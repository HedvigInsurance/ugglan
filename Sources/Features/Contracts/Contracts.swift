//
//  Contracts.swift
//  FeatureContracts
//
//  Created by Sam Pettersson on 2020-03-11.
//

import Foundation
import Presentation
import UIKit
import Flow
import ComponentKit

public struct Contracts {
    public init() {}
}

extension Contracts: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = String(key: .TAB_DASHBOARD_TITLE)
        bag += viewController.install(List())
        return (viewController, bag)
    }
}

extension Contracts: Tabable {
    public func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: String(key: .TAB_DASHBOARD_TITLE),
            image: Asset.dashboardTab.image,
            selectedImage: nil
        )
    }
}

