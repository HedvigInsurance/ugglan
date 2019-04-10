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
    let referralsEnabled: Bool

    init(
        client: ApolloClient = ApolloContainer.shared.client,
        referralsEnabled: Bool = RemoteConfigContainer.shared.referralsEnabled()
    ) {
        self.client = client
        self.referralsEnabled = referralsEnabled
    }
}

extension Profile: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.displayableTitle = "Profil"

        let form = FormView()

        let referralSectionStyle = DynamicSectionStyle.sectionPlain.restyled { (style: inout SectionStyle) in
            style.background = .highlighted
        }

        let referralSection = SectionView(rows: [], style: referralSectionStyle)

        let referralRow = ReferralRow(
            presentingViewController: viewController
        )
        bag += referralSection.append(referralRow)

        form.append(referralSection)

        let referralSpacing = Spacing(height: 20)
        bag += form.append(referralSpacing)

        let referralsHidden = referralsEnabled ? false : true

        referralSection.isHidden = referralsHidden
        referralSpacing.isHiddenSignal.value = referralsHidden

        let profileSection = ProfileSection(
            presentingViewController: viewController
        )

        bag += form.append(profileSection)

        bag += form.append(Spacing(height: 20))

        let otherSection = OtherSection(
            presentingViewController: viewController
        )

        bag += form.append(otherSection)

        bag += form.append(Spacing(height: 20))

        let logoutSection = LogoutSection(
            presentingViewController: viewController
        )

        bag += form.append(logoutSection)

        let query = ProfileQuery()

        bag += client.watch(query: query)
            .compactMap { $0.data }
            .bindTo(profileSection.dataSignal)

        bag += viewController.install(form) { scrollView in
            let refreshControl = UIRefreshControl()
            bag += self.client.refetchOnRefresh(query: query, refreshControl: refreshControl)

            scrollView.addRefreshControl(refreshControl)
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
