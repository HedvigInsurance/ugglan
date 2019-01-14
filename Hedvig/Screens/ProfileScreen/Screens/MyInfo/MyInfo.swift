//
//  MyInfo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-04.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct MyInfo {
    let client: ApolloClient

    init(client: ApolloClient = HedvigApolloClient.shared.client!) {
        self.client = client
    }
}

extension MyInfo: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String.translation(.MY_INFO_TITLE)

        if #available(iOS 11.0, *) {
            viewController.navigationItem.largeTitleDisplayMode = .never
        }

        let form = FormView()
        
        let nameCircle = NameCircle()
        
        bag += form.prepend(nameCircle) { _, containerView in
            containerView.snp.makeConstraints({ make in
                make.height.equalTo(200)
            })
        }
        
        let section = form.appendSection(
            header: String.translation(.MY_INFO_CONTACT_DETAILS_TITLE),
            footer: nil,
            style: .sectionPlain
        )
        
        bag += viewController.install(form) { scrollView in
            bag += scrollView.chainAllControlResponders(shouldLoop: false, returnKey: .next)
        }

        return (viewController, bag)
    }
}
