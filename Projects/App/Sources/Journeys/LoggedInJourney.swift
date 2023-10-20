import Claims
import Contracts
import Embark
import Flow
import Forever
import Form
import Foundation
import Home
import MoveFlow
import Payment
import Presentation
import Profile
import SwiftUI
import TerminateContracts
import TravelCertificate
import hAnalytics
import hCore
import hCoreUI

extension AppJourney {
    fileprivate static var homeTab: some JourneyPresentation {
        let claims = Claims()
        return
            HomeView.journey(
                claimsContent: claims,
                memberId: {
                    let profileStrore: ProfileStore = globalPresentableStoreContainer.get()
                    return profileStrore.state.memberDetails?.id ?? ""
                }
            ) { result in
                switch result {
                case .startMovingFlow:
                    AppJourney.movingFlow()
                case .openFreeTextChat:
                    AppJourney.freeTextChat().withDismissButton
                case .openConnectPayments:
                    PaymentSetup(setupType: .initial).journeyThenDismiss
                case .startNewClaim:
                    AppJourney.startClaimsJourney(from: .generic)
                case .openTravelInsurance:
                    TravelInsuranceFlowJourney.start {
                        AppJourney.freeTextChat()
                    }
                case .openCrossSells:
                    CrossSellingScreen.journey { result in
                        if case .openCrossSellingWebUrl(let url) = result {
                            AppJourney.webRedirect(url: url)
                        }
                    }
                }
            }
            .makeTabSelected(UgglanStore.self) { action in
                if case .makeTabActive(let deepLink) = action {
                    return deepLink == .home
                } else {
                    return false
                }
            }
            .configureClaimsNavigation
            .configureSubmitClaimsNavigation
            .configurePaymentNavigation
    }

    fileprivate static var contractsTab: some JourneyPresentation {
        Contracts.journey { result in
            switch result {
            case .movingFlow:
                AppJourney.movingFlow()
            case .openFreeTextChat:
                AppJourney.freeTextChat().withDismissButton
            case let .openCrossSellingWebUrl(url):
                AppJourney.webRedirect(url: url)
            case let .startNewTermination(action):
                TerminationFlowJourney.start(for: action)
            }
        }
        .makeTabSelected(UgglanStore.self) { action in
            if case .makeTabActive(let deepLink) = action {
                return deepLink == .insurances
            } else {
                return false
            }
        }
    }

    fileprivate static var foreverTab: some JourneyPresentation {
        ForeverView.journey()
            .makeTabSelected(UgglanStore.self) { action in
                if case .makeTabActive(let deepLink) = action {
                    return deepLink == .forever
                } else {
                    return false
                }
            }
    }

    fileprivate static var profileTab: some JourneyPresentation {
        ProfileView.journey { result in
            switch result {
            case .openPayment:
                HostingJourney(
                    PaymentStore.self,
                    rootView: MyPaymentsView(urlScheme: Bundle.main.urlScheme ?? "")
                ) { action in
                    if case .openConnectBankAccount = action {
                        let store: PaymentStore = globalPresentableStoreContainer.get()
                        let hasAlreadyConnected = [PayinMethodStatus.active, PayinMethodStatus.pending]
                            .contains(store.state.paymentStatusData?.status ?? .active)
                        ConnectBankAccount(
                            setupType: hasAlreadyConnected ? .replacement : .initial,
                            urlScheme: Bundle.main.urlScheme ?? ""
                        )
                        .journeyThenDismiss
                    } else if case .openHistory = action {
                        PaymentHistory.journey
                    } else if case let .openPayoutBankAccount(options) = action {
                        AdyenPayOut(adyenOptions: options, urlScheme: Bundle.main.urlScheme ?? "")
                            .journey({ _ in
                                DismissJourney()
                            })
                            .setStyle(.detented(.medium, .large))
                            .setOptions([.defaults, .allowSwipeDismissAlways])
                            .withJourneyDismissButton
                    }
                }
                .configureTitle(L10n.myPaymentTitle)
            case .resetAppLanguage:
                ContinueJourney()
                    .onPresent {
                        UIApplication.shared.appDelegate.bag += UIApplication.shared.appDelegate.window.present(
                            AppJourney.main
                        )
                    }
            case .openChat:
                AppJourney.freeTextChat().withDismissButton
            case .logout:
                ContinueJourney()
                    .onPresent {
                        UIApplication.shared.appDelegate.logout()
                    }
            case .registerForPushNotifications:
                ContinueJourney()
                    .onPresent {
                        _ = UIApplication.shared.appDelegate
                            .registerForPushNotifications()
                    }
            }
        }
        .makeTabSelected(UgglanStore.self) { action in
            if case .makeTabActive(let deepLink) = action {
                return deepLink == .profile || deepLink == .sasEuroBonus
            } else {
                return false
            }
        }
    }

    static var loggedIn: some JourneyPresentation {
        Journey(ExperimentsLoader(), options: []) { _ in
            TabbedJourney(
                {
                    homeTab
                },
                {
                    contractsTab
                },
                {
                    if hAnalyticsExperiment.forever {
                        foreverTab
                    }
                },
                {
                    profileTab
                }
            )
            .sendActionImmediately(ContractStore.self, .fetch)
            .sendActionImmediately(ForeverStore.self, .fetch)
            .sendActionImmediately(ClaimsStore.self, .fetchClaims)
            .syncTabIndex()
            .onAction(UgglanStore.self) { action in
                if action == .openChat {
                    freeTextChat(style: .unlessAlreadyPresented(style: .detented(.large)))
                        .withDismissButton
                }
            }
            .onPresent {
                ApplicationState.preserveState(.loggedIn)
                AnalyticsCoordinator().setUserId()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    ApplicationContext.shared.$isLoggedIn.value = true
                }
            }
        }
        .onDismiss {
            ApplicationContext.shared.$isLoggedIn.value = false
        }
    }
}

extension JourneyPresentation {
    @discardableResult
    func sendActionImmediately<S: Store>(
        _ storeType: S.Type,
        _ action: S.Action
    ) -> Self {
        return self.onPresent {
            let store: S = self.presentable.get()
            store.send(action)
        }
    }

    public var configureClaimsNavigation: some JourneyPresentation {
        onAction(ClaimsStore.self) { action in
            if case let .openClaimDetails(claim) = action {
                AppJourney.claimDetailJourney(claim: claim)
            } else if case let .submitNewClaim(origin) = action {
                AppJourney.startClaimsJourney(from: origin)
                    .onAction(SubmitClaimStore.self) { action in
                        if case .dissmissNewClaimFlow = action {
                            DismissJourney()
                        }
                    }
            } else if case .openFreeTextChat = action {
                AppJourney.freeTextChat().withDismissButton
            }
        }
    }

    public var configureSubmitClaimsNavigation: some JourneyPresentation {
        onAction(SubmitClaimStore.self) { action in
            if case .submitClaimOpenFreeTextChat = action {
                AppJourney.freeTextChat()
            }
        }
        .onAction(
            SubmitClaimStore.self,
            { action, pre in
                if case let .navigationAction(navigationAction) = action {
                    if case .openSuccessScreen = navigationAction {
                        let store: ProfileStore = globalPresentableStoreContainer.get()
                        store.send(.setPushNotificationsTo(date: nil))
                    }
                }
            }
        )
    }

    public var configurePaymentNavigation: some JourneyPresentation {
        onAction(PaymentStore.self) { action in
            if case .connectPayments = action {
                PaymentSetup(setupType: .initial).journeyThenDismiss
            }
        }
    }
}
