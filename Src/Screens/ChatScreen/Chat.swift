//
//  Chat.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-06.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Presentation
import UIKit

struct Chat {}

extension Chat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height - 100)
        
        Chat.didOpen()

        let view = UIView()
        view.backgroundColor = .purple

        viewController.view = view

        return (viewController, Future { _ in
            bag
        })
    }
}

extension Chat: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(title: "Chat", image: nil, selectedImage: nil)
    }
}
