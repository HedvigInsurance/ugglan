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

        let referralsInvitationsTable = ReferralsInvitationsTable()
        bag += formView.append(referralsInvitationsTable) { tableView in
            bag += tableView.didLayoutSignal.onValue { _ in
                tableView.snp.remakeConstraints { make in
                    make.height.equalTo(tableView.contentSize.height)
                }
            }
        }

        bag += formView.append(Spacing(height: 50))

        let linkSignal = ReadWriteSignal<String?>(nil)
        
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
            ).compactMap { $1 }.onValue { _ in
                let activityView = ActivityView(
                    activityItems: [""],
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
