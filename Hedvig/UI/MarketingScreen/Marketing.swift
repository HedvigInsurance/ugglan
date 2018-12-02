//  Marketing.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-25.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Presentation
import SnapKit
import UIKit

struct Marketing {
    let client: ApolloClient
}

extension Marketing: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let containerView = UIView()
        containerView.backgroundColor = HedvigColors.white
        viewController.view = containerView

        let storiesCollection = StoriesCollection(
            client: client,
            containerView: containerView
        )
        bag += containerView.add(storiesCollection)

        return (viewController, bag)
    }
}
