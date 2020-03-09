//
//  Referrals.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-15.
//

import Apollo
import Firebase
import FirebaseAnalytics
import FirebaseDynamicLinks
import FirebaseFirestore
import Flow
import Form
import Foundation
import Presentation
import UIKit
import Common
import Space

enum ReferralsFailure: LocalizedError {
    case failedToCreateLink
}

struct Referrals {
    @Inject var client: ApolloClient
    @Inject var remoteConfigContainer: RemoteConfigContainer
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
        scrollView.backgroundColor = .primaryBackground

        let formView = FormView()
        formView.spacing = 20
        bag += viewController.install(
            formView,
            scrollView: scrollView
        )

        let query = ReferralsScreenQuery()

        let refreshControl = UIRefreshControl()
        bag += client.refetchOnRefresh(query: query, refreshControl: refreshControl)

        scrollView.refreshControl = refreshControl

        let codeSignal = ReadWriteSignal<String?>(nil)

        let referralsScreenQuerySignal = client
            .watch(query: query)
            .wait(until: formView.hasWindowSignal)

        bag += referralsScreenQuerySignal
            .compactMap { $0.data?.referralInformation.campaign.code }
            .bindTo(codeSignal)

        let invitationsSignal = ReadWriteSignal<[InvitationsListRow]?>(nil)
        let peopleLeftToInviteSignal = ReadWriteSignal<Int?>(nil)

        let incentiveSignal = ReadWriteSignal<Int?>(nil)

        bag += referralsScreenQuerySignal
            .compactMap { $0.data?.referralInformation.campaign.incentive?.asMonthlyCostDeduction?.amount?.amount }
            .toInt()
            .bindTo(incentiveSignal)

        let netPremiumSignal = ReadWriteSignal<Int?>(nil)

        bag += referralsScreenQuerySignal
            .compactMap { $0.data?.insurance.cost?.fragments.costFragment.monthlyNet.amount }
            .toInt()
            .bindTo(netPremiumSignal)

        let grossPremiumSignal = ReadWriteSignal<Int?>(nil)

        bag += referralsScreenQuerySignal
            .compactMap { $0.data?.insurance.cost?.fragments.costFragment.monthlyGross.amount }
            .toInt()
            .bindTo(grossPremiumSignal)

        bag += combineLatest(netPremiumSignal.compactMap { $0 }, incentiveSignal.compactMap { $0 })
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

                    if let acceptedReferral = invitation.asAcceptedReferral {
                        return .right(ReferralsInvitationAnonymous(count: acceptedReferral.quantity))
                    }

                    if let terminatedReferral = invitation.asTerminatedReferral {
                        return .left(ReferralsInvitation(name: terminatedReferral.name, state: .left))
                    }

                    return .right(ReferralsInvitationAnonymous(count: 0))
                }
            }.bindTo(invitationsSignal)

        let referredBySignal = ReadWriteSignal<InvitationsListRow?>(nil)

        bag += referralsScreenQuerySignal
            .compactMap { $0.data?.referralInformation.referredBy }
            .map { referral -> InvitationsListRow in
                if let activeReferral = referral.asActiveReferral {
                    return .left(ReferralsInvitation(name: activeReferral.name, state: .invitedYou))
                }

                if let inProgressReferral = referral.asInProgressReferral {
                    return .left(ReferralsInvitation(name: inProgressReferral.name, state: .onboarding))
                }

                if let acceptedReferral = referral.asAcceptedReferral {
                    return .right(ReferralsInvitationAnonymous(count: acceptedReferral.quantity))
                }

                if let terminatedReferral = referral.asTerminatedReferral {
                    return .left(ReferralsInvitation(name: terminatedReferral.name, state: .left))
                }

                return .right(ReferralsInvitationAnonymous(count: 1))
            }.bindTo(referredBySignal)

        let content = ReferralsContent(
            codeSignal: codeSignal.readOnly().compactMap { $0 },
            referredBySignal: referredBySignal.readOnly(),
            invitationsSignal: invitationsSignal.readOnly(),
            peopleLeftToInviteSignal: peopleLeftToInviteSignal.readOnly(),
            incentiveSignal: incentiveSignal.readOnly(),
            netPremiumSignal: netPremiumSignal.readOnly(),
            grossPremiumSignal: grossPremiumSignal.readOnly(),
            presentingViewController: viewController
        )
        let loadableContent = LoadableView(view: content, initialLoadingState: true)

        bag += codeSignal.compactMap { $0 }.map { _ in false }.bindTo(loadableContent.isLoadingSignal)

        bag += formView.prepend(loadableContent)

        bag += formView.append(Spacing(height: 50))

        let button = LoadableButton(
            button: Button(
                title: String(key: .REFERRALS_SHARE_BUTTON),
                type: .standard(backgroundColor: .primaryTintColor, textColor: .white)
            ),
            initialLoadingState: true
        )

        bag += scrollView.add(button.wrappedIn(UIView())) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.bottom.equalTo(
                    scrollView.safeAreaLayoutGuide.snp.bottom
                ).inset(20)
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(button.button.type.value.height)
            }

            bag += buttonView.applyShadow { _ in
                UIView.ShadowProperties(
                    opacity: 0.5,
                    offset: CGSize(width: 0, height: 6),
                    radius: 8,
                    color: UIColor.primaryShadowColor,
                    path: nil
                )
            }

            bag += codeSignal.compactMap { _ = $0 }.map { false }.bindTo(button.isLoadingSignal)

            bag += button.onTapSignal.withLatestFrom(
                codeSignal.plain()
            ).compactMap { $1 }.onValue { code in
                let landingPageUrl = "\(self.remoteConfigContainer.referralsWebLandingPrefix)\(code)"
                let message = String(key: .REFERRAL_SMS_MESSAGE(
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

                bag += activityView.completionSignal.onValueDisposePrevious { activity, success in
                    let innerBag = bag.innerBag()

                    if success {
                        let register = PushNotificationsRegister(
                            title: String(key: .PUSH_NOTIFICATIONS_ALERT_TITLE),
                            message: String(key: .PUSH_NOTIFICATIONS_REFERRALS_ALERT_MESSSAGE)
                        )

                        innerBag += viewController.present(register)

                        if activity != nil {
                            let activity = activity?.rawValue.replacingOccurrences(of: ".", with: "_")
                            Analytics.logEvent("referrals_share", parameters: ["activity": activity ?? "nil_activity"])
                        }
                    }

                    return innerBag
                }
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
