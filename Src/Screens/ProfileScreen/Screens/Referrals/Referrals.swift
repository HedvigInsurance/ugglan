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

        let referralsIllustration = ReferralsIllustration()
        bag += formView.prepend(referralsIllustration) { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(210)
            }
        }

        let referralsTitle = ReferralsTitle()
        bag += formView.append(referralsTitle)

        let referralsOfferSender = ReferralsOffer(mode: .sender)
        bag += formView.append(referralsOfferSender)

        let referralsOfferReceiver = ReferralsOffer(mode: .receiver)
        bag += formView.append(referralsOfferReceiver)

        let section = SectionView(rows: [], style: .sectionPlain)

        let termsRow = ReferralsTermsRow(
            presentingViewController: viewController
        )
        bag += section.append(termsRow)

        formView.append(section)

        bag += formView.append(Spacing(height: 50))

        let linkSignal = ReadWriteSignal<String?>(nil)

//        bag += client.fetch(query: MemberIdQuery()).valueSignal.compactMap {
//            $0.data?.member.id
//        }.onValue { memberId in
//            bag += self.createInvitationLink(memberId: memberId).bindTo(linkSignal)
//        }

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
                //let incentive = String(self.remoteConfigContainer.referralsIncentive())
                //let shareMessage = String(key: .REFERRALS_SHARE_MESSAGE(incentive: incentive, link: link))

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
