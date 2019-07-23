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

        bag += Disposer {
            Chat.didClose()
        }

        let view = UIView()
        view.backgroundColor = .purple
        
        let dummyButton = Button(title: "yoo", type: .outline(borderColor: .white, textColor: .white))
        bag += view.add(dummyButton) { dummyButton in
            dummyButton.snp.makeConstraints({ make in
                make.width.equalToSuperview()
                make.height.equalToSuperview()
            })
        }
        
        bag += dummyButton.onTapSignal.onValue { _ in
            UIApplication.shared.appDelegate.createToast(symbol: .character("🤖"), body: "HELLO BITCH")
        }

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
