//
//  Referrals.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-15.
//

import Apollo
import Firebase
#if canImport(FirebaseDynamicLinks)
    import FirebaseDynamicLinks
#endif
#if canImport(FirebaseFirestore)
    import FirebaseFirestore
#endif
import Flow
import Form
import Foundation
import Presentation
import UIKit

enum ReferralsFailure: LocalizedError {
    case failedToCreateLink
}

struct Referrals {
    let client: ApolloClient
    let remoteConfigContainer: RemoteConfigContainer

    init(
        client: ApolloClient = ApolloContainer.shared.client,
        remoteConfigContainer: RemoteConfigContainer = RemoteConfigContainer.shared
    ) {
        self.client = client
        self.remoteConfigContainer = remoteConfigContainer
    }

    func createInvitationLink(memberId: String) -> Future<String> {
        return Future { completion in
            let incentive = self.remoteConfigContainer.referralsIncentive()

            guard let link = URL(
                string: String(
                    key:
                    .REFERRALS_DYNAMIC_LINK_LANDING(
                        incentive: String(incentive),
                        memberId: memberId
                    )
                )
            ) else {
                return NilDisposer()
            }

            let domainUriPrefix = self.remoteConfigContainer.dynamicLinkDomainPrefix()

            let linkBuilder = DynamicLinkComponents(
                link: link,
                domainURIPrefix: domainUriPrefix
            )

            linkBuilder?.iOSParameters = DynamicLinkIOSParameters(
                bundleID: self.remoteConfigContainer.dynamicLinkiOSBundleId()
            )
            linkBuilder?.iOSParameters?.appStoreID = self.remoteConfigContainer.dynamicLinkiOSAppStoreId()
            linkBuilder?.androidParameters = DynamicLinkAndroidParameters(
                packageName: self.remoteConfigContainer.dynamicLinkAndroidPackageName()
            )

            linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
            linkBuilder?.socialMetaTagParameters?.title = String(key: .REFERRAL_SHARE_SOCIAL_TITLE)
            linkBuilder?.socialMetaTagParameters?.descriptionText = String(key: .REFERRAL_SHARE_SOCIAL_DESCRIPTION)

            if let imageUrl = URL(string: String(key: .REFERRAL_SHARE_SOCIAL_IMAGE_URL)) {
                linkBuilder?.socialMetaTagParameters?.imageURL = imageUrl
            }

            linkBuilder?.shorten { url, _, error in
                if error != nil {
                    completion(.failure(ReferralsFailure.failedToCreateLink))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                }
            }

            return NilDisposer()
        }
    }
}

extension Referrals: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = String(key: .REFERRALS_SCREEN_TITLE)

        let bag = DisposeBag()

        let scrollView = UIScrollView()
        scrollView.backgroundColor = .offWhite

        let formView = FormView()
        formView.spacing = 20
        bag += viewController.install(
            formView,
            scrollView: scrollView
        )
        
        let referralsProgressBar = ReferralsProgressBar(amountOfBlocks: 20, amountOfCompletedBlocks: 2)
        bag += formView.prepend(referralsProgressBar) { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(350)
            }
        }

        let referralsTitle = ReferralsTitle()
        bag += formView.append(referralsTitle)
        
        let referralsCodeContainer = ReferralsCodeContainer()
        bag += formView.append(referralsCodeContainer)

        bag += formView.append(Spacing(height: 50))

        let linkSignal = ReadWriteSignal<String?>(nil)

        bag += client.fetch(query: MemberIdQuery()).valueSignal.compactMap {
            $0.data?.member.id
        }.onValue { memberId in
            bag += self.createInvitationLink(memberId: memberId).bindTo(linkSignal)
        }

        let button = LoadableButton(
            button: Button(
                title: String(key: .REFERRALS_SHARE_BUTTON),
                type: .standard(backgroundColor: .purple, textColor: .white)
            ),
            initialLoadingState: true
        )

        bag += scrollView.add(button) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.bottom.equalTo(
                    viewController.bottomLayoutGuide.snp.bottom
                ).inset(20)
                make.centerX.equalToSuperview()
            }

            bag += linkSignal.compactMap { _ = $0 }.map { false }.bindTo(button.isLoadingSignal)

            bag += button.onTapSignal.withLatestFrom(
                linkSignal.plain()
            ).compactMap { $1 }.onValue { link in
                let incentive = String(self.remoteConfigContainer.referralsIncentive())
                let shareMessage = String(key: .REFERRALS_SHARE_MESSAGE(incentive: incentive, link: link))

                let activityView = ActivityView(
                    activityItems: [shareMessage],
                    applicationActivities: nil,
                    sourceView: buttonView,
                    sourceRect: buttonView.bounds
                )

                viewController.present(activityView)
            }
        }

        return (viewController, bag)
    }
}
