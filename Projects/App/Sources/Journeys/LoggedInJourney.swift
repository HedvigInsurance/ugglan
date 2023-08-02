import Claims
import Contracts
import Embark
import Flow
import Forever
import Form
import Foundation
import Home
import Payment
import Presentation
import SwiftUI
import TravelCertificate
import hAnalytics
import hCore
import hCoreUI

extension AppJourney {
    fileprivate static var homeTab: some JourneyPresentation {
        let claims = Claims()
        let commonClaims = CommonClaimsView()
        return
            HomeView.journey(
                claimsContent: claims,
                commonClaimsContent: commonClaims,
                memberId: {
                    let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
                    return ugglanStore.state.memberDetails?.id ?? ""

                }
            ) { result in
                switch result {
                case .startMovingFlow:
                    AppJourney.movingFlow
                case .openFreeTextChat:
                    AppJourney.freeTextChat().withDismissButton
                case .openConnectPayments:
                    PaymentSetup(setupType: .initial).journeyThenDismiss
                }
            } statusCard: {
                VStack(spacing: 16) {
                    ConnectPaymentCardView()
                    RenewalCardView()
                }
            }
            .onTabSelected {
                GradientState.shared.gradientType = .home
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
            .onAction(
                HomeStore.self,
                { action, _ in
                    if case .openTravelInsurance = action {
                        do {
                            Task {
                                let data = try await TravelInsuranceFlowJourney.getTravelCertificate()
                                let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
                                claimsStore.send(.openCommonClaimDetail(commonClaim: data.asCommonClaim()))
                            }
                        } catch let _ {
                            //TODO: ERROR
                        }
                    }
                }
            )
    }

    fileprivate static var contractsTab: some JourneyPresentation {
        Contracts.journey { result in
            switch result {
            case .movingFlow:
                AppJourney.movingFlow
            case .openFreeTextChat:
                AppJourney.freeTextChat().withDismissButton
            case let .openCrossSellingDetail(crossSell):
                AppJourney.crossSellingJourney(crossSell: crossSell)
            case let .openCrossSellingEmbark(name):
                AppJourney.crossSellingEmbarkJourney(name: name, style: .detented(.large))
            case let .openCrossSellingWebUrl(url):
                AppJourney.webRedirect(url: url)
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
            } else if case .openTravelInsurance = action {
                TravelInsuranceFlowJourney.start {
                    AppJourney.freeTextChat()
                }
            } else if case .openHowClaimsWork = action {
                AppJourney.claimsInfoJourney()
            } else if case let .openCommonClaimDetail(commonClaim) = action {
                AppJourney.commonClaimDetailJourney(claim: commonClaim)
            } else if case .openFreeTextChat = action {
                AppJourney.freeTextChat()
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
                        let store: UgglanStore = globalPresentableStoreContainer.get()
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
