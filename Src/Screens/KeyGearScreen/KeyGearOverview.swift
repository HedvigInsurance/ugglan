//
//  Stuff.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-23.
//

import Foundation
import Presentation
import UIKit
import Flow
import Form
import Apollo

struct KeyGearOverview {
    @Inject var client: ApolloClient
}

extension KeyGearOverview: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = "Prylar"
        
        let formView = FormView()
        
        bag += formView.prepend(TabHeader(image: Asset.claimsHeader.image, title: "Hej hej", description: "Hej hej"))
        
        let button = UIButton(title: "TAP ME")
        formView.append(button)
        bag += button.onValue { _ in
            bag += viewController.present(
                KeyGearInfo().withCloseButton,
                style: .modally(
                    presentationStyle: .pageSheet,
                    transitionStyle: nil,
                    capturesStatusBarAppearance: false
                )
            ).disposable
        }
        bag += formView.append(KeyGearListCollection()).onValue { result in
            switch result {
            case .add:
                viewController.present(AddKeyGearItem(), style: .modally()).onValue { _ in
                    viewController.present(KeyGearItem(name: "test"), style: .default, options: [.largeTitleDisplayMode(.never)])
                }
            case .row:
                viewController.present(KeyGearItem(name: "test"), style: .default, options: [.largeTitleDisplayMode(.never)])
            }
        }
        
        let refreshControl = UIRefreshControl()
        bag += client.refetchOnRefresh(query: OfferQuery(), refreshControl: refreshControl)
        
        bag += viewController.install(formView) { scrollView in
            scrollView.refreshControl = refreshControl
        }
        
        return (viewController, bag)
    }
}

extension KeyGearOverview: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(title: nil, image: nil, selectedImage: nil)
    }
}
