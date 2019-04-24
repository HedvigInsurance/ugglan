//
//  Claims.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-12.
//

import Foundation
import Flow
import Presentation
import Apollo
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
        viewController.title = "Skador"
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        
        let claimsHeader = ClaimsHeader(presentingViewController: viewController)
        bag += stackView.addArangedSubview(claimsHeader)
        
        let commonClaimsCollection = CommonClaimsCollection(presentingViewController: viewController)
        
        bag += stackView.addArangedSubview(commonClaimsCollection)
        
        bag += viewController.install([stackView])
        
        return (viewController, bag)
    }
}

extension Claims: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: "Skador",
            image: Asset.claimsTabIcon.image,
            selectedImage: Asset.claimsTabIcon.image
        )
    }
}
