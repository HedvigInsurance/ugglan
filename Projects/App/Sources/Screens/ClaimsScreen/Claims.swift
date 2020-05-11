//
//  Claims.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-12.
//

import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import Core

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

        let commonClaimsCollection = CommonClaimsCollection(presentingViewController: viewController)

        bag += stackView.addArranged(commonClaimsCollection)

        bag += viewController.install([stackView])

        return (viewController, bag)
    }
}

extension Claims: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: L10n.claimsScreenTab,
            image: Asset.claimsTabIcon.image,
            selectedImage: Asset.claimsTabIcon.image
        )
    }
}
