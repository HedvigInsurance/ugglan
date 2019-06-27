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

        let referralsScreenQuerySignal = client
            .fetch(query: ReferralsScreenQuery())
            .valueSignal
            .wait(until: formView.hasWindowSignal)

        bag += referralsScreenQuerySignal
            .compactMap { $0.data?.referralInformation.campaign.code }
            .bindTo(codeSignal)

        let invitationsSignal = ReadWriteSignal<[InvitationsListRow]?>(nil)
        let peopleLeftToInviteSignal = ReadWriteSignal<Int?>(nil)

        let incentiveSignal = referralsScreenQuerySignal
            .compactMap { $0.data?.referralInformation.campaign.incentive?.asMonthlyCostDeduction?.amount?.amount }
            .toInt()
            .compactMap { $0 }

        let netPremiumSignal = referralsScreenQuerySignal
            .compactMap { $0.data?.insurance.cost?.monthlyNet.amount }
            .toInt()
            .compactMap { $0 }

        let grossPremiumSignal = referralsScreenQuerySignal
            .compactMap { $0.data?.insurance.cost?.monthlyGross.amount }
            .toInt()
            .compactMap { $0 }

        bag += netPremiumSignal
            .withLatestFrom(incentiveSignal)
            .map { netPremium, incentive in Int(round(Double(netPremium) / Double(incentive))) }
            .map { count in max(0, count) }
            .bindTo(peopleLeftToInviteSignal)

        bag += referralsScreenQuerySignal
            .compactMap { $0.data?.referralInformation.invitations }
            .map { invitations -> [InvitationsListRow] in
                invitations.map { invitation in
                    if let activeReferral = invitation.asActiveReferral {
                        return .left(ReferralsInvitation(name: activeReferral.name, state: .member))
                    }

                    if let inProgressReferral = invitation.asInProgressReferral {
                        return .left(ReferralsInvitation(name: inProgressReferral.name, state: .onboarding))
                    }

                    if invitation.asNotInitiatedReferral != nil {
                        return .right(ReferralsInvitationAnonymous(count: 1))
                    }

                    if let terminatedReferral = invitation.asTerminatedReferral {
                        return .left(ReferralsInvitation(name: terminatedReferral.name, state: .left))
                    }

                    return .right(ReferralsInvitationAnonymous(count: 1))
                }
            }.bindTo(invitationsSignal)
        
        let referredBySignal = ReadWriteSignal<InvitationsListRow?>(nil)
        
        bag += referralsScreenQuerySignal
            .compactMap { $0.data?.referralInformation.referredBy }
            .map { referral -> InvitationsListRow in
                if let activeReferral = referral.asActiveReferral {
                    return .left(ReferralsInvitation(name: activeReferral.name, state: .member))
                }
                
                if let inProgressReferral = referral.asInProgressReferral {
                    return .left(ReferralsInvitation(name: inProgressReferral.name, state: .onboarding))
                }
                
                if referral.asNotInitiatedReferral != nil {
                    return .right(ReferralsInvitationAnonymous(count: 1))
                }
                
                if let terminatedReferral = referral.asTerminatedReferral {
                    return .left(ReferralsInvitation(name: terminatedReferral.name, state: .left))
                }
                
                return .right(ReferralsInvitationAnonymous(count: 1))
        }.bindTo(referredBySignal)

        let content = ReferralsContent(
            codeSignal: codeSignal.readOnly().compactMap { $0 },
            referredBySignal: referredBySignal.plain(),
            invitationsSignal: invitationsSignal.readOnly().compactMap { $0 },
            peopleLeftToInviteSignal: peopleLeftToInviteSignal.readOnly().compactMap { $0 },
            incentiveSignal: incentiveSignal,
            netPremiumSignal: netPremiumSignal,
            grossPremiumSignal: grossPremiumSignal
        )
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
                let landingPageUrl = "\(self.remoteConfigContainer.referralsWebLandingPrefix)\(code)"
                let message = String(key: .REFERRAL_SMS_MESSAGE(
                    referralCode: code,
                    referralLink: landingPageUrl,
                    referralValue: "10"
                ))

                let activityView = ActivityView(
                    activityItems: [message],
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

extension Referrals: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: String(key: .TAB_REFERRALS_TITLE),
            image: Asset.referralsTab.image,
            selectedImage: Asset.referralsTab.image
        )
    }
}
