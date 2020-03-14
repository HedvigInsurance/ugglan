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

struct Contracts {}

extension Contracts: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        return (viewController, bag)
    }
}

extension Contracts: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: String(key: .TAB_DASHBOARD_TITLE),
            image: Asset.dashboardTab.image,
            selectedImage: nil
        )
    }
}

