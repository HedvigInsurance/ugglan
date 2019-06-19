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

    init(
        client: ApolloClient = ApolloContainer.shared.client
    ) {
        self.client = client
    }
}

extension Referrals: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String(key: .REFERRALS_SCREEN_TITLE)

        let moreInfoBarButton = UIBarButtonItem(
            title: String(key: .REFERRAL_PROGRESS_TOPBAR_BUTTON),
            style: .navigationBarButton
        )

        bag += moreInfoBarButton.onValue { _ in
            viewController.present(
                DraggableOverlay(
                    presentable: ReferralsMoreInfo(),
                    presentationOptions: [.defaults, .prefersNavigationBarHidden(true)]
                )
            )
        }

        viewController.navigationItem.rightBarButtonItem = moreInfoBarButton

        let scrollView = UIScrollView()
        scrollView.backgroundColor = .offWhite

        let formView = FormView()
        formView.spacing = 20
        bag += viewController.install(
            formView,
            scrollView: scrollView
        )
        
        let codeSignal = ReadWriteSignal<String?>(nil)
        
        bag += client
            .fetch(query: ReferralCodeQuery())
            .valueSignal
            .compactMap { $0.data?.memberReferralCampaign?.referralInformation.code }
            .bindTo(codeSignal)
        
        let content = ReferralsContent(codeSignal: codeSignal.readOnly().compactMap { $0 })
        let loadableContent = LoadableView(view: content, initialLoadingState: true)
        
        bag += codeSignal.compactMap { $0 }.map { _ in false }.bindTo(loadableContent.isLoadingSignal)
        
        bag += formView.prepend(loadableContent)

        bag += formView.append(Spacing(height: 50))

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

            bag += codeSignal.compactMap { _ = $0 }.map { false }.bindTo(button.isLoadingSignal)

            bag += button.onTapSignal.withLatestFrom(
                codeSignal.plain()
            ).compactMap { $1 }.onValue { code in
                let activityView = ActivityView(
                    activityItems: [code],
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
