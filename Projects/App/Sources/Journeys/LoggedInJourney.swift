import Claims
import Contracts
import EditCoInsured
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
                case .openEmergency:
                    SubmitClaimEmergencyScreen.journey
                case .openHelpCenter:
                    HelpCenterStartView.journey
                case .openCrossSells:
                    CrossSellingScreen.journey { result in
                        if case .openCrossSellingWebUrl(let url) = result {
                            AppJourney.webRedirect(url: url)
                        }
                    }
                case let .startCoInsuredFlow(contractIds):
                    AppJourney.editCoInsured(configs: contractIds)
                case let .goToQuickAction(quickAction):
                    AppJourney.configureQuickAction(quickAction: quickAction)
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
            .configureContractNavigation
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
        let store: PaymentStore = globalPresentableStoreContainer.get()
        store.send(.setSchema(schema: Bundle.main.urlScheme ?? ""))
        return
            ProfileView.journey { result in
                switch result {
                case .openPayment:
                    PaymentsView().journey(schema: Bundle.main.urlScheme ?? "")
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
            .onAction(HomeStore.self) { action in
                if case let .openDocument(url) = action {
                    Journey(
                        Document(url: url, title: L10n.insuranceCertificateTitle),
                        style: .detented(.large)
                    )
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
            if case let .navigation(navigateTo) = action {
                if case .openConnectPayments = navigateTo {
                    PaymentSetup(setupType: .initial).journeyThenDismiss
                }
            }
        }
    }

    public var configureContractNavigation: some JourneyPresentation {
        onAction(
            EditCoInsuredStore.self,
            { action in
                if case let .coInsuredNavigationAction(navAction) = action {
                    if case let .openMissingCoInsuredAlert(config) = navAction {
                        EditCoInsuredJourney.openMissingCoInsuredAlert(config: config)
                    }
                } else if case let .openEditCoInsured(contractId, fromInfoCard) = action {
                    EditCoInsuredJourney.handleOpenEditCoInsured(for: contractId, fromInfoCard: fromInfoCard)
                } else if case .goToFreeTextChat = action {
                    AppJourney.freeTextChat().withDismissButton
                }
            }
        )
        .onAction(EditCoInsuredStore.self) { action, pre in
            if case .fetchContracts = action {
                let store: ContractStore = globalPresentableStoreContainer.get()
                store.send(.fetchContracts)

            } else if case .checkForAlert = action {
                let store: ContractStore = globalPresentableStoreContainer.get()
                let editStore: EditCoInsuredStore = globalPresentableStoreContainer.get()

                let missingContract = store.state.activeContracts.first { contract in
                    if contract.upcomingChangedAgreement != nil {
                        return false
                    } else {
                        return contract.coInsured
                            .first(where: { coInsured in
                                coInsured.hasMissingInfo && contract.terminationDate == nil
                            }) != nil
                    }
                }
                if let missingContract {
                    editStore.send(
                        .coInsuredNavigationAction(
                            action: .openMissingCoInsuredAlert(config: .init(contract: missingContract))
                        )
                    )
                }
            }
        }
    }
}
