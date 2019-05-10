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

struct Claims {
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension Claims: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String(key: .CLAIMS_SCREEN_TITLE)
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
            title: String(key: .CLAIMS_SCREEN_TAB),
            image: Asset.claimsTabIcon.image,
            selectedImage: Asset.claimsTabIcon.image
        )
    }
}
