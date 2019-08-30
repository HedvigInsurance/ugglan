//
//  UIViewController+TabBarBadge.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-15.
//

import Foundation
import UIKit

extension UIViewController {
    func updateTabBarItemBadge(value: String?, backgroundColor: UIColor = .attentionTintColor) {
        let topMostViewController: UIViewController = navigationController != nil ? navigationController! : self
        guard let index = self.tabBarController?.viewControllers?.firstIndex(of: topMostViewController) else {
            return log.warning("Can't update badge, not a part of a tabBarController")
        }
        guard let tabBarItem = self.tabBarController?.tabBar.items?[index] else {
            return log.warning("Can't update badge, coudn't find tabBarItem")
        }
        tabBarItem.badgeColor = backgroundColor
        tabBarItem.badgeValue = value
    }
}
