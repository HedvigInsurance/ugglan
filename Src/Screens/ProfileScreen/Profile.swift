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
    @Inject var client: ApolloClient
}

extension Profile: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.displayableTitle = String(key: .PROFILE_TITLE)
        viewController.installChatButton()

        let form = FormView()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)

        let profileSection = ProfileSection(
            presentingViewController: viewController
        )
        
        bag += stackView.addArranged(profileSection)
        
        bag += stackView.addArranged(Spacing(height: 20))

        let otherSection = OtherSection(
            presentingViewController: viewController
        )
        
        bag += stackView.addArranged(otherSection)
        
        bag += stackView.addArranged(Spacing(height: 20))

        let logoutSection = LogoutSection(
            presentingViewController: viewController
        )
        
        bag += stackView.addArranged(logoutSection)

        let query = ProfileQuery()

        bag += client.watch(query: query)
            .compactMap { $0.data }
            .bindTo(profileSection.dataSignal)
        
        form.append(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(form.safeAreaLayoutGuide)
        }

        bag += viewController.install(form) { scrollView in
            let refreshControl = UIRefreshControl()
            bag += self.client.refetchOnRefresh(query: query, refreshControl: refreshControl)

            scrollView.refreshControl = refreshControl
            bag += scrollView.chainAllControlResponders(shouldLoop: true, returnKey: .next)
        }

        return (viewController, bag)
    }
}

extension Profile: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: String(key: .TAB_PROFILE_TITLE),
            image: Asset.profileTab.image,
            selectedImage: nil
        )
    }
}
