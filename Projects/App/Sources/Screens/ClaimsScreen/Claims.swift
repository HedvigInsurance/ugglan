//
//  Claims.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-12.
//

import Apollo
import Flow
import Foundation
import hCore
import Presentation
import UIKit

struct Claims {
    @Inject var client: ApolloClient
}

extension Claims: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = L10n.claimsScreenTitle
        viewController.installChatButton()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 0, verticalInset: 25)

        let claimsHeader = ClaimsHeader(presentingViewController: viewController)
        bag += stackView.addArranged(claimsHeader)

        bag += viewController.install([stackView])

        return (viewController, bag)
    }
}

extension Claims: Tabable {
    func tabBarItem() -> UITabBarItem {
        UITabBarItem(
            title: L10n.claimsScreenTab,
            image: Asset.claimsTabIcon.image,
            selectedImage: Asset.claimsTabIcon.image
        )
    }
}
