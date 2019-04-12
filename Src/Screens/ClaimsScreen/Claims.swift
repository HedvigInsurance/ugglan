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
        
        let headerView = UIView()
        headerView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        stackView.addArrangedSubview(headerView)
        
        bag += stackView.addArangedSubview(CommonClaimsCollection()) { collectionView in
            bag += collectionView.didLayoutSignal.onValue({ _ in
                collectionView.snp.updateConstraints({ make in
                    make.height.equalTo(
                        collectionView.collectionViewLayout.collectionViewContentSize.height
                    )
                })
            })
        }
        
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
