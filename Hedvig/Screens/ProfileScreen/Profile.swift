//
//  Profile.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-02.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct Profile {
    let client: ApolloClient
}

extension Profile: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.displayableTitle = "Profil"

        let form = FormView()
        
        bag += client.fetch(query: ProfileQuery()).onValue { result in
            let profileSection = ProfileSection(
                data: result.data,
                presentingViewController: viewController
            )

            bag += form.append(profileSection)
        }

        bag += viewController.install(form) { scrollView in
            let refreshControl = UIRefreshControl()

            bag += refreshControl.onValue({ _ in
                bag += Signal(after: 2).onValue({ _ in
                    refreshControl.endRefreshing()
                })
            })

            scrollView.addRefreshControl(refreshControl)
            bag += scrollView.chainAllControlResponders(shouldLoop: true, returnKey: .next)
        }

        return (viewController, bag)
    }
}
