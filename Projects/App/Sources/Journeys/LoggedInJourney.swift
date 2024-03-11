import Chat
import Claims
import Contracts
import EditCoInsured
import Flow
import Forever
import Foundation
import Home
import MoveFlow
import Payment
import Presentation
import Profile
import SafariServices
import SwiftUI
import TerminateContracts
import TravelCertificate
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
                case let .openFreeTextChat(topic):
                    AppJourney.freeTextChat(withTopic: topic).withDismissButton
                case .startNewClaim:
                    AppJourney.startClaimsJourney(from: .generic)
                case .openCrossSells:
                    CrossSellingScreen.journey { result in
                        if case .openCrossSellingWebUrl(let url) = result {
                            AppJourney.urlHandledBySystem(url: url)
                        }
                    }
                case let .startCoInsuredFlow(contractIds):
                    AppJourney.editCoInsured(configs: contractIds)
                case let .goToQuickAction(quickAction):
                    AppJourney.configureQuickAction(commonClaim: quickAction)
                case let .goToURL(url):
                    AppJourney.configureURL(url: url)
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
            .configureChatNavigation
            .configureTerminationNavigation
            .configureTravelCertificateNavigation
    }

    fileprivate static var contractsTab: some JourneyPresentation {
        Contracts.journey { result in
            switch result {
            case .movingFlow:
                AppJourney.movingFlow()
            case .openFreeTextChat:
                AppJourney.freeTextChat().withDismissButton
            case let .openCrossSellingWebUrl(url):
                AppJourney.urlHandledBySystem(url: url)
            case let .startNewTermination(action):
                TerminationFlowJourney.start(for: action)
                    .onDismiss {
                        let store: ContractStore = globalPresentableStoreContainer.get()
                        store.send(.fetch)
                    }
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
            .onAction(ProfileStore.self) { action, pre in
                if case let .goToURL(url) = action {
                    if let vc = UIApplication.shared.getTopViewController() {
                        if let deepLink = DeepLink.getType(from: url) {
                            if deepLink.tabURL {
                                let store: ProfileStore = globalPresentableStoreContainer.get()
                                store.send(.dismissScreen(openChatAfter: false))
                            }
                            UIApplication.shared.appDelegate.handleDeepLink(url, fromVC: vc)
                        } else {
                            let journey = AppJourney.webRedirect(url: url)
                            pre.bag += pre.viewController.present(journey)
                        }
                    }
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
                    let store: ContractStore = globalPresentableStoreContainer.get()
                    if !store.state.activeContracts.allSatisfy({ $0.isNonPayingMember })
                        || store.state.activeContracts.isEmpty
                    {
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
                let coordinator: AnalyticsCoordinator = Dependencies.shared.resolve()
                coordinator.setUserId()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    ApplicationContext.shared.$isLoggedIn.value = true
                }
                let profileStore: ProfileStore = globalPresentableStoreContainer.get()
                profileStore.send(.fetchMemberDetails)
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
            } else if case let .openDocument(url, title) = action {
                Journey(
                    Document(url: url, title: title),
                    style: .detented(.large)
                )
            }
        }
    }

    public var configureSubmitClaimsNavigation: some JourneyPresentation {
        onAction(SubmitClaimStore.self) { action in
            if case .submitClaimOpenFreeTextChat = action {
                AppJourney.freeTextChat().withJourneyDismissButton
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

    public var configureTerminationNavigation: some JourneyPresentation {
        onAction(TerminationContractStore.self) { action in
            if case let .goToUrl(url) = action {
                AppJourney.configureURL(url: url)
            } else if case .goToFreeTextChat = action {
                AppJourney.freeTextChat().withDismissButton
            }
        }
    }

    public var configureTravelCertificateNavigation: some JourneyPresentation {
        onAction(TravelInsuranceStore.self) { action in
            if case .goToEditCoInsured = action {
                AppJourney.configureQuickAction(commonClaim: .editCoInsured())
            }
        }
    }

    public var configureChatNavigation: some JourneyPresentation {
        onAction(ChatStore.self) { action, pre in
            if case let .setLastMessageDate(date) = action {
                let store: HomeStore = globalPresentableStoreContainer.get()
                if store.state.latestChatTimeStamp != date {
                    store.send(
                        .setChatNotificationTimeStamp(
                            sentAt: date
                        )
                    )
                }
            } else if case let .navigation(navigationAction) = action {
                switch navigationAction {
                case let .linkClicked(url):
                    if let vc = UIApplication.shared.getTopViewController() {
                        if DeepLink.getType(from: url) != nil {
                            UIApplication.shared.appDelegate.handleDeepLink(url, fromVC: vc)
                        } else {
                            let journey = AppJourney.webRedirect(url: url)
                            pre.bag += pre.viewController.present(journey)
                        }
                    }
                case .closeChat:
                    break
                }
            } else if case .checkPushNotificationStatus = action {
                let profileStore: ProfileStore = globalPresentableStoreContainer.get()
                let status = profileStore.state.pushNotificationCurrentStatus()
                switch status {
                case .denied:
                    func createToast() -> Toast {
                        let schema = UITraitCollection.current.userInterfaceStyle
                        return Toast(
                            symbol: .icon(hCoreUIAssets.infoIconFilled.image),
                            body: L10n.chatToastPushNotificationsTitle,
                            infoText: L10n.pushNotificationsAlertActionOk,
                            textColor: hSignalColor.blueText.colorFor(schema == .dark ? .dark : .light, .base).color
                                .uiColor(),
                            backgroundColor: hSignalColor.blueFill.colorFor(schema == .dark ? .dark : .light, .base)
                                .color
                                .uiColor(),
                            symbolColor: hSignalColor.blueElement.colorFor(schema == .dark ? .dark : .light, .base)
                                .color
                                .uiColor(),
                            duration: 6
                        )
                    }

                    let toast = createToast()

                    pre.bag += toast.onTap.onValue { _ in
                        UIApplication.shared.appDelegate.registerForPushNotifications().sink()
                    }
                    Toasts.shared.displayToast(toast: toast)
                default:
                    break
                }
            }
        }
    }
}
