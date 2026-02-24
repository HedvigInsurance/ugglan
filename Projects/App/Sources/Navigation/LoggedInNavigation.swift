import Addons
import ChangeTier
import Chat
import Claims
import Combine
import Contracts
import CrossSell
import EditCoInsured
import Environment
import Forever
import Foundation
import Home
import InsuranceEvidence
import Market
import MoveFlow
import Payment
import PresentableStore
import Profile
import SafariServices
import SubmitClaim
import SubmitClaimChat
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import TerminateContracts
import TravelCertificate
import hCore
import hCoreUI

// MARK: - Helper Classes

@MainActor
class PushNotificationHandler {
    weak var viewModel: LoggedInNavigationViewModel?

    func handle(_ notification: Notification) {
        guard let object = notification.object as? PushNotificationType else { return }

        switch object {
        case .NEW_MESSAGE:
            handleNewMessage(notification)
        case .OPEN_FOREVER_TAB, .REFERRAL_SUCCESS, .REFERRALS_ENABLED:
            handleForeverTab()
        case .CONNECT_DIRECT_DEBIT:
            handleConnectDirectDebit()
        case .PAYMENT_FAILED:
            handlePaymentFailed()
        case .CROSS_SELL, .OPEN_INSURANCE_TAB:
            handleInsuranceTab()
        case .OPEN_CONTACT_INFO:
            handleContactInfo()
        case .CHANGE_TIER:
            handleChangeTierNotification(notification)
        case .ADDON_TRAVEL:
            Task { await handleAddon(type: .travelPlus, contractId: nil) }
        case .ADDON_CAR_PLUS:
            Task { await handleAddon(type: .carPlus, contractId: nil) }
        case .OPEN_CLAIM, .CLAIM_CLOSED:
            handleClaimNotification(notification)
        case .INSURANCE_EVIDENCE:
            handleInsuranceEvidence()
        case .TRAVEL_CERTIFICATE:
            handleTravelCertificate()
        }
    }

    private func handleNewMessage(_ notification: Notification) {
        let userInfo = notification.userInfo
        let conversationId = userInfo?["conversationId"] as? String
        NotificationCenter.default.post(
            name: .openChat,
            object: ChatType.conversationId(id: conversationId ?? "")
        )
    }

    private func handleForeverTab() {
        UIApplication.shared.getRootViewController()?.dismiss(animated: true)
        viewModel?.selectedTab = 2
    }

    private func handleConnectDirectDebit() {
        viewModel?.homeNavigationVm.connectPaymentVm.set()
    }

    private func handlePaymentFailed() {
        UIApplication.shared.getRootViewController()?.dismiss(animated: true)
        viewModel?.selectedTab = 3
    }

    private func handleInsuranceTab() {
        UIApplication.shared.getRootViewController()?.dismiss(animated: true)
        viewModel?.selectedTab = 1
    }

    private func handleContactInfo() {
        UIApplication.shared.getRootViewController()?.dismiss(animated: true)
        viewModel?.selectedTab = 4
        viewModel?.profileNavigationVm.pushToProfile()
    }

    private func handleChangeTierNotification(_ notification: Notification) {
        UIApplication.shared.getRootViewController()?.dismiss(animated: true)
        let userInfo = notification.userInfo
        let contractId = userInfo?["contractId"] as? String
        handleChangeTier(contractId: contractId)
    }

    private func handleClaimNotification(_ notification: Notification) {
        let userInfo = notification.userInfo
        let claimId = userInfo?["claimId"] as? String
        Task { await handleClaimDetails(claimId: claimId) }
    }

    private func handleTravelCertificate() {
        viewModel?.isTravelInsurancePresented = true
    }

    func handleChangeTier(contractId: String?) {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        if let contractId, let contract: Contracts.Contract = contractStore.state.contractForId(contractId) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak viewModel] in
                viewModel?.isChangeTierPresented = .init(
                    source: .changeTier,
                    contracts: [
                        .init(
                            contractId: contractId,
                            contractDisplayName: contract.currentAgreement?.productVariant.displayName ?? "",
                            contractExposureName: contract.exposureDisplayName
                        )
                    ]
                )
            }
        } else {
            let contractsSupportingChangingTier: [ChangeTierContract] = contractStore.state.activeContracts
                .filter(\.supportsChangeTier)
                .map {
                    .init(
                        contractId: $0.id,
                        contractDisplayName: $0.currentAgreement?.productVariant.displayName ?? "",
                        contractExposureName: $0.exposureDisplayName
                    )
                }
            viewModel?.isChangeTierPresented = ChangeTierContractsInput(
                source: .changeTier,
                contracts: contractsSupportingChangingTier
            )
        }
    }

    func handleAddon(type: AddonBanner.AddonType, contractId: String?) async {
        do {
            let client: FetchContractsClient = Dependencies.shared.resolve()

            // take the first one that hast same type
            if let addonBanner = try await client.getAddonBanners(source: .deeplink)
                .filter({ $0.addonType == type })
                .first
            {
                let contractStore: ContractStore = globalPresentableStoreContainer.get()

                let addonContracts = addonBanner.contractIds.compactMap {
                    contractStore.state.contractForId($0)
                }

                guard !addonContracts.isEmpty else {
                    throw AddonsError.missingContracts
                }

                let addonConfigs = addonContracts.map {
                    AddonConfig(
                        contractId: $0.id,
                        exposureName: $0.exposureDisplayName,
                        displayName: $0.currentAgreement?.productVariant.displayName ?? ""
                    )
                }
                viewModel?.isAddonPresented = .init(
                    addonSource: .deeplink,
                    contractConfigs: addonConfigs
                )
            }
        } catch {
            viewModel?.isAddonErrorPresented = error.localizedDescription
        }
    }

    func handleClaimDetails(claimId: String?) async {
        guard let viewModel = viewModel else { return }
        if let claimId {
            let claimService: hFetchClaimDetailsClient = Dependencies.shared.resolve()
            do {
                let claim = try await claimService.get(for: claimId)
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                viewModel.selectedTab = 0
                Task { [weak viewModel] in
                    try await Task.sleep(seconds: 0.2)
                    viewModel?.homeNavigationVm.router.push(claim)
                }
            } catch {
                Toasts.shared.displayToastBar(toast: .init(type: .error, text: L10n.General.defaultError))
            }
        } else {
            Toasts.shared.displayToastBar(toast: .init(type: .error, text: L10n.General.defaultError))
        }
    }

    func handleInsuranceEvidence() {
        Task { [weak viewModel] in
            do {
                let profileClient: ProfileClient = Dependencies.shared.resolve()
                let canCreate = try await profileClient.getProfileState().canCreateInsuranceEvidence
                if canCreate {
                    viewModel?.isInsuranceEvidencePresented = true
                }
            } catch {}
        }
    }
}

@MainActor
class DeepLinkHandler {
    weak var viewModel: LoggedInNavigationViewModel?

    func handle(_ deepLinkUrl: URL?) {
        guard let url = deepLinkUrl else { return }
        guard let deepLink = DeepLink.getType(from: url) else {
            if !Environment.current.isDeeplink(url) {
                viewModel?.openUrl(url: url)
            }
            return
        }

        switch deepLink {
        case .forever:
            dismissAndSelectTab(2)
        case .directDebit:
            viewModel?.homeNavigationVm.connectPaymentVm.set()
        case .profile:
            dismissAndSelectTab(4)
        case .insurances:
            dismissAndSelectTab(1)
        case .home:
            dismissAndSelectTab(0)
        case .sasEuroBonus:
            viewModel?.isEuroBonusPresented = true
        case .contract:
            handleContractDeeplink(url)
        case .payments:
            dismissAndSelectTab(3)
        case .travelCertificate:
            viewModel?.isTravelInsurancePresented = true
        case .insuranceEvidence:
            viewModel?.handleInsuranceEvidence()
        case .helpCenter:
            handleHelpCenterDeeplink(url)
        case .helpCenterTopic:
            handleHelpCenterTopic(url)
        case .helpCenterQuestion:
            handleHelpCenterQuestion(url)
        case .moveContract:
            viewModel?.isMoveContractPresented = true
        case .terminateContract:
            handleTerminateContract(url)
        case .conversation:
            handleDeeplinkConversation(url)
        case .chat, .inbox:
            NotificationCenter.default.post(name: .openChat, object: ChatType.inbox)
        case .contactInfo:
            handleDeeplinkContactInfo(url)
        case .changeTier:
            viewModel?.handleChangeTier(contractId: url.getParameter(property: .contractId))
        case .travelAddon:
            Task { [weak viewModel] in
                await viewModel?.handleAddon(type: .travelPlus, contractId: url.getParameter(property: .contractId))
            }
        case .carPlusAddon:
            Task { [weak viewModel] in
                await viewModel?.handleAddon(type: .carPlus, contractId: url.getParameter(property: .contractId))
            }

        case .editCoInsured:
            handleEditCoInsured(url: url)
        case .claimDetails:
            Task { [weak viewModel] in
                await viewModel?.handleClaimDetails(claimId: url.getParameter(property: .claimId))
            }
        case .submitClaim:
            viewModel?.selectedTab = 0
            viewModel?.homeNavigationVm.isSubmitClaimPresented = true
        case .claimChat:
            handleChatClaimDeeplink(url)
        }
    }

    private func handleChatClaimDeeplink(_ url: URL) {
        dismissAndSelectTab(0)
        if let messageId = url.getParameter(property: .sourceMessageId) {
            viewModel?.homeNavigationVm.claimsAutomationStartInput = .init(sourceMessageId: messageId)
        }
    }

    private func dismissAndSelectTab(_ tab: Int) {
        UIApplication.shared.getRootViewController()?.dismiss(animated: true)
        viewModel?.selectedTab = tab
    }

    private func handleContractDeeplink(_ url: URL) {
        dismissAndSelectTab(1)
        let contractId = url.getParameter(property: .contractId)

        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        if let contractId, let contract: Contracts.Contract = contractStore.state.contractForId(contractId) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak viewModel] in
                viewModel?.contractsNavigationVm.contractsRouter.popToRoot()
                viewModel?.contractsNavigationVm.contractsRouter.push(contract)
            }
        }
    }

    private func handleHelpCenterDeeplink(_ url: URL) {
        dismissAndSelectTab(0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak viewModel] in
            viewModel?.homeNavigationVm.isHelpCenterPresented = true
        }
    }

    private func handleHelpCenterTopic(_ url: URL) {
        if let id = url.getParameter(property: .id) {
            Task { [weak viewModel] in
                let store: HomeStore = globalPresentableStoreContainer.get()
                if store.state.helpCenterFAQModel == nil {
                    await store.sendAsync(.fetchFAQ)
                }
                if let helpCenterFAQModel = store.state.helpCenterFAQModel,
                    let topic = helpCenterFAQModel.topics.first(where: { $0.id == id })
                {
                    viewModel?.isFaqTopicPresented = topic
                }
            }
        }
    }

    private func handleHelpCenterQuestion(_ url: URL) {
        if let id = url.getParameter(property: .id) {
            Task { [weak viewModel] in
                let store: HomeStore = globalPresentableStoreContainer.get()
                if store.state.getAllFAQ()?.first(where: { $0.id == id }) == nil {
                    await store.sendAsync(.fetchFAQ)
                }
                if let question = store.state.getAllFAQ()?.first(where: { $0.id == id }) {
                    viewModel?.isFaqPresented = question
                }
            }
        }
    }

    private func handleTerminateContract(_ url: URL) {
        guard let viewModel = viewModel else { return }
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        let contractId = url.getParameter(property: .contractId)
        if let contractId, let contract: Contracts.Contract = contractStore.state.contractForId(contractId) {
            Task { [weak viewModel] in
                do {
                    try await Task.sleep(seconds: 0.2)
                    let contractsConfig = [contract.asTerminationConfirmConfig]
                    try await viewModel?.terminateInsuranceVm.start(with: contractsConfig)
                } catch let exception {
                    Toasts.shared.displayToastBar(
                        toast: .init(type: .error, text: exception.localizedDescription)
                    )
                }
            }
        } else {
            Task { [weak viewModel] in
                do {
                    try await Task.sleep(seconds: 0.2)
                    let contractsConfig = contractStore.state.activeContracts
                        .filter(\.canTerminate)
                        .map(\.asTerminationConfirmConfig)
                    try await viewModel?.terminateInsuranceVm.start(with: contractsConfig)
                } catch let exception {
                    Toasts.shared.displayToastBar(
                        toast: .init(type: .error, text: exception.localizedDescription)
                    )
                }
            }
        }
    }

    private func handleDeeplinkConversation(_ url: URL) {
        let conversationId = url.getParameter(property: .conversationId)
        Task {
            let conversationClient: ConversationsClient = Dependencies.shared.resolve()
            let conversations = try await conversationClient.getConversations()
            let isValidConversation = conversations.first(where: { $0.id == conversationId })

            if let conversationId, isValidConversation != nil {
                NotificationCenter.default.post(
                    name: .openChat,
                    object: ChatType.conversationId(id: conversationId)
                )
            } else {
                NotificationCenter.default.post(name: .openChat, object: ChatType.inbox)
            }
        }
    }

    private func handleDeeplinkContactInfo(_ url: URL) {
        dismissAndSelectTab(4)
        viewModel?.profileNavigationVm.pushToProfile()
    }

    private func handleEditCoInsured(url: URL) {
        guard let viewModel = viewModel else { return }
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        Task {
            if let contractId = url.getParameter(property: .contractId),
                let contract: Contracts.Contract = contractStore.state.contractForId(contractId)
            {
                let contractConfig: InsuredPeopleConfig = .init(contract: contract, fromInfoCard: false)

                if contract.nbOfMissingCoInsuredWithoutTermination != 0 {
                    viewModel.homeNavigationVm.editCoInsuredVm
                        .start(
                            fromContract: contractConfig,
                            forMissingCoInsured: true
                        )
                } else {
                    viewModel.homeNavigationVm.editCoInsuredVm.start(fromContract: contractConfig)
                }
            } else {
                // select insurance
                viewModel.homeNavigationVm.editCoInsuredVm.start(fromContract: nil)
            }
        }
    }
}

// MARK: - Views

struct LoggedInNavigation: View {
    @ObservedObject var vm: LoggedInNavigationViewModel
    @StateObject private var router = Router()
    @StateObject private var foreverRouter = Router()
    @StateObject private var paymentsRouter = Router()
    @EnvironmentObject private var mainNavigationVm: MainNavigationViewModel
    @InjectObservableObject private var features: FeatureFlags
    var body: some View {
        TabView(selection: $vm.selectedTab) {
            homeTab
            contractsTab

            let store: ContractStore = globalPresentableStoreContainer.get()
            if !store.state.activeContracts.allSatisfy(\.isNonPayingMember)
                || store.state.activeContracts.isEmpty
            {
                foreverTab
            }

            if features.isPaymentScreenEnabled {
                paymentsTab
            }
            profileTab
        }
        .tint(hTextColor.Opaque.primary)
        .handleLoggedInPresentations(with: vm)
        .introspect(.tabView, on: .iOS(.v13...)) { tabBar in
            vm.tabBar = tabBar
        }
        .detent(
            presented: $vm.askForPushNotification,
            options: .constant(.withoutGrabber)
        ) { [weak vm] in
            AskForPushNotifications(
                text: L10n.claimsActivateNotificationsBody,
                onActionExecuted: {
                    vm?.askForPushNotification = false
                },
                wrapWithForm: true
            )
            .embededInNavigation(
                tracking: "AskForPushNotifications"
            )
        }
    }

    var homeTab: some View {
        HomeTab(homeNavigationVm: vm.homeNavigationVm, loggedInVm: vm)
            .environmentObject(router)
            .tabItem {
                vm.selectedTab == 0 ? hCoreUIAssets.homeTabActive.view : hCoreUIAssets.homeTab.view
                hText(L10n.tabHomeTitle)
            }
            .tag(0)
    }

    var contractsTab: some View {
        ContractsNavigation(contractsNavigationVm: vm.contractsNavigationVm) { redirectType in
            switch redirectType {
            case .chat:
                ChatScreen(
                    vm: .init(
                        chatService: NewConversationService()
                    )
                )
            case .movingFlow:
                HandleMoving()
            case let .pdf(document):
                PDFPreview(document: document)
            case let .changeTier(input):
                ChangeTierNavigation(input: input)
            }
        } redirectAction: { action in
            switch action {
            case let .termination(terminateAction):
                switch terminateAction {
                case .done:
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    contractStore.send(.fetchContracts)
                    let homeStore: HomeStore = globalPresentableStoreContainer.get()
                    homeStore.send(.fetchQuickActions)
                case .chat:
                    NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                case let .openFeedback(url):
                    vm.openUrl(url: url)
                case .changeTierFoundBetterPriceStarted, .changeTierMissingCoverageAndTermsStarted:
                    break
                }
            }
        }
        .handleEditCoInsured(with: vm.contractsNavigationVm.editCoInsuredVm)
        .tabItem {
            vm.selectedTab == 1
                ? hCoreUIAssets.contractTabActive.view : hCoreUIAssets.contractTab.view
            hText(L10n.tabInsurancesTitle)
        }
        .tag(1)
    }

    private func fetchContracts() {
        // added delay since we don't have a terms version at the place right after the insurance has been created
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let store: ContractStore = globalPresentableStoreContainer.get()
            store.send(.fetchContracts)
        }
    }

    var foreverTab: some View {
        ForeverNavigation(useOwnNavigation: true)
            .environmentObject(foreverRouter)
            .tabItem {
                vm.selectedTab == 2 ? hCoreUIAssets.foreverTabActive.view : hCoreUIAssets.foreverTab.view
                hText(L10n.tabReferralsTitle)
            }
            .tag(2)
    }

    var paymentsTab: some View {
        PaymentsNavigation(paymentsNavigationVm: vm.paymentsNavigationVm)
            .environmentObject(paymentsRouter)
            .tabItem {
                vm.selectedTab == 3
                    ? hCoreUIAssets.paymentsTabActive.view : hCoreUIAssets.paymentsTab.view
                hText(L10n.tabPaymentsTitle)
            }
            .tag(3)
    }

    var profileTab: some View {
        ProfileNavigation(profileNavigationViewModel: vm.profileNavigationVm) { redirectType in
            switch redirectType {
            case .travelCertificate:
                TravelCertificateNavigation(
                    vm: vm.travelCertificateNavigationVm,
                    infoButtonPlacement: .trailing,
                    useOwnNavigation: false
                )
                .handleEditCoInsured(
                    with: vm.travelCertificateNavigationVm.editCoInsuredVm
                )
            case .deleteAccount:
                let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
                let contractsStore: ContractStore = globalPresentableStoreContainer.get()
                let model = DeleteAccountViewModel(
                    claimsStore: claimsStore,
                    contractsStore: contractsStore
                )

                DeleteAccountView(
                    vm: model
                )
                .environmentObject(vm.profileNavigationVm)
            case .pickLanguage:
                LanguagePickerView {
                    [weak profileNavigationVm = vm.profileNavigationVm, weak mainNavigationVm, weak vm] in
                    // show loading screen since we everything needs to be updated
                    mainNavigationVm?.hasLaunchFinished = false
                    profileNavigationVm?.isLanguagePickerPresented = false
                    let store: ProfileStore = globalPresentableStoreContainer.get()
                    store.send(.updateLanguage)
                    // show home screen with updated langauge
                    mainNavigationVm?.loggedInVm = .init()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak mainNavigationVm, weak vm] in
                        mainNavigationVm?.hasLaunchFinished = true
                        vm?.selectedTab = 0
                    }
                } onCancel: { [weak profileNavigationVm = vm.profileNavigationVm] in
                    profileNavigationVm?.isLanguagePickerPresented = false
                }
            case let .deleteRequestLoading(state):
                DeleteRequestLoadingView(
                    screenState: state,
                    dismissAction: { [weak vm] profileDismissAction in
                        switch profileDismissAction {
                        case .makeHomeTabActiveAndOpenChat:
                            vm?.selectedTab = 0
                            NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                        default:
                            vm?.selectedTab = 0
                        }
                    }
                )
                .embededInNavigation(tracking: ProfileRedirectType.deleteRequestLoading(state: state))
            }
        }
        .tabItem {
            vm.selectedTab == 4 ? hCoreUIAssets.profileTabActive.view : hCoreUIAssets.profileTab.view
            hText(L10n.ProfileTab.title)
        }
        .tag(4)
    }
}

struct HandleMoving: View {
    var body: some View {
        MovingFlowNavigation(
            onMoved: {
                let store: ContractStore = globalPresentableStoreContainer.get()
                store.send(.fetchContracts)
            }
        )
    }
}

struct HomeTab: View {
    @ObservedObject var homeNavigationVm: HomeNavigationViewModel
    @ObservedObject var loggedInVm: LoggedInNavigationViewModel
    @State var showOldSubmitClaimFlow = false
    var body: some View {
        RouterHost(router: homeNavigationVm.router, tracking: self) {
            HomeScreen()
                .routerDestination(for: ClaimModel.self, options: [.hidesBottomBarWhenPushed]) { claim in
                    openClaimDetails(claim: claim, type: .claim(id: claim.id))
                }
                .routerDestination(for: HomeRouterAction.self) { _ in
                    InboxView()
                        .environmentObject(homeNavigationVm)
                }
        }
        .environmentObject(homeNavigationVm)
        .handleConnectPayment(with: homeNavigationVm.connectPaymentVm)
        .handleEditCoInsured(with: homeNavigationVm.editCoInsuredVm)
        .detent(
            presented: $homeNavigationVm.isSubmitClaimPresented,
            options: .constant(.withoutGrabber)
        ) {
            ClaimsMainNavigation()
                .environmentObject(homeNavigationVm)
        }
        .handleClaimFlow(
            startInput: $homeNavigationVm.claimsAutomationStartInput,
            showOldSubmitClaimFlow: $showOldSubmitClaimFlow
        )
        .modally(presented: $showOldSubmitClaimFlow) {
            SubmitClaimNavigation()
        }
        .modally(
            presented: $homeNavigationVm.isHelpCenterPresented
        ) {
            HelpCenterNavigation(
                helpCenterVm: loggedInVm.helpCenterVm
            ) { redirectType in
                switch redirectType {
                case .moveFlow:
                    HandleMoving()
                case .travelInsurance:
                    TravelCertificateNavigation(
                        vm: loggedInVm.travelCertificateNavigationVm,
                        infoButtonPlacement: .leading,
                        useOwnNavigation: true
                    )
                    .handleEditCoInsured(
                        with: loggedInVm.travelCertificateNavigationVm.editCoInsuredVm
                    )
                case .deflect:
                    let model: FlowClaimDeflectStepModel = {
                        let partners: [Partner] = {
                            let store: HomeStore = globalPresentableStoreContainer.get()
                            let quickActions = store.state.quickActions
                            if let sickAbroadPartners = quickActions.first(where: { $0.sickAboardPartners != nil })?
                                .sickAboardPartners
                            {
                                let partners: [Partner] = sickAbroadPartners.compactMap {
                                    Partner(
                                        id: $0.id,
                                        imageUrl: $0.imageUrl,
                                        url: $0.url,
                                        phoneNumber: $0.phoneNumber,
                                        title: L10n.submitClaimEmergencyGlobalAssistanceTitle,
                                        description: L10n.submitClaimEmergencyGlobalAssistanceLabel,
                                        info: L10n.submitClaimGlobalAssistanceFootnote,
                                        buttonText: L10n.submitClaimGlobalAssistanceUrlLabel,
                                        preferredImageHeight: $0.preferredImageHeight
                                    )
                                }

                                return partners
                            }
                            return []
                        }()
                        return FlowClaimDeflectStepModel.emergency(with: partners)
                    }()

                    SubmitClaimDeflectScreen(
                        model: model,
                        openChat: {
                            NotificationCenter.default.post(
                                name: .openChat,
                                object: ChatType.newConversation
                            )
                        }
                    )
                    .configureTitle(model.id.title)
                    .withDismissButton()
                    .embededInNavigation(
                        options: [.navigationType(type: .large), .extendedNavigationWidth],
                        tracking: LoggedInNavigationDetentType.submitClaimDeflect
                    )
                }
            }
            .handleEditCoInsured(
                with: loggedInVm.helpCenterVm.editCoInsuredVm
            )
            .environmentObject(homeNavigationVm)
        }
        .detent(
            presented: $homeNavigationVm.navBarItems.isFirstVetPresented,
            transitionType: .detent(style: [.large])
        ) {
            let store: HomeStore = globalPresentableStoreContainer.get()
            FirstVetView(partners: store.state.quickActions.getFirstVetPartners ?? [])
                .configureTitle(QuickAction.firstVet(partners: []).displayTitle)
                .embededInNavigation(
                    options: [.navigationType(type: .large), .extendedNavigationWidth],
                    tracking: LoggedInNavigationDetentType.firstVet
                )
        }
        .detent(
            item: $homeNavigationVm.navBarItems.isNewOfferPresentedCenter,
            transitionType: .center,
            options: .constant([.alwaysOpenOnTop])
        ) { crossSell in
            CrossSellingCentered(crossSell: crossSell)
        }
        .detent(
            item: $homeNavigationVm.navBarItems.isNewOfferPresentedModal,
            transitionType: .detent(style: [.large]),
            options: .constant([.alwaysOpenOnTop, .withoutGrabber])
        ) { crossSells in
            CrossSellingModal(crossSells: crossSells)
        }
        .detent(
            item: $homeNavigationVm.navBarItems.isNewOfferPresentedDetent,
            transitionType: .detent(style: [.height]),
            options: .constant([.alwaysOpenOnTop])
        ) { crossSells in
            CrossSellingDetent(crossSells: crossSells)
        }
        .detent(
            item: $homeNavigationVm.openChat,
            transitionType: .detent(style: [.large]),
            options: $homeNavigationVm.openChatOptions,
            content: { openChat in
                ChatNavigation(
                    chatType: openChat.chatType,
                    redirectView: { viewType, onDone in
                        switch viewType {
                        case .notification:
                            AskForPushNotifications(
                                text: L10n.chatActivateNotificationsBody,
                                onActionExecuted: {
                                    onDone()
                                }
                            )
                        case let .claimDetailFor(claimId: claimId):
                            openClaimDetails(claim: nil, type: .conversation(claimId: claimId))
                        }
                    }
                )
            }
        )
    }

    private func openClaimDetails(claim: ClaimModel?, type: ClaimDetailsType) -> some View {
        ClaimDetailView(claim: claim, type: type)
            .configureTitle(L10n.claimsYourClaim)
            .onDeinit {
                Task {
                    let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
                    if claim?.showClaimClosedFlow ?? false, let claim = claim {
                        NotificationCenter.default.post(name: .openCrossSell, object: claim.asCrossSellInfo)
                        let service: hFetchClaimDetailsClient = Dependencies.shared.resolve()
                        try await service.acknowledgeClosedStatus(for: claim.id)
                        claimsStore.send(.fetchActiveClaims)
                    }
                }
            }
    }
}

enum LoggedInNavigationDetentType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .submitClaimDeflect:
            return .init(describing: SubmitClaimDeflectScreen.self)
        case .firstVet:
            return .init(describing: FirstVetView.self)
        case .error:
            return .init(describing: GenericErrorView.self)
        }
    }

    case submitClaimDeflect
    case firstVet
    case error
}

@MainActor
class LoggedInNavigationViewModel: ObservableObject {
    @Published var selectedTab = 0 {
        willSet {
            previousTab = selectedTab
        }
    }

    let hasLaunchFinished = CurrentValueSubject<Bool, Never>(false)
    var hasLaunchFinishedCancellable: AnyCancellable?
    var previousTab: Int = 0

    // MARK: - Helper Properties
    private let pushNotificationHandler = PushNotificationHandler()
    private let deepLinkHandler = DeepLinkHandler()

    let contractsNavigationVm = ContractsNavigationViewModel()
    let paymentsNavigationVm = PaymentsNavigationViewModel()
    let profileNavigationVm = ProfileNavigationViewModel()
    let homeNavigationVm = HomeNavigationViewModel()
    let helpCenterVm = HelpCenterNavigationViewModel()
    let travelCertificateNavigationVm = TravelCertificateNavigationViewModel()
    let terminateInsuranceVm = TerminateInsuranceViewModel()

    @Published var isTravelInsurancePresented = false
    @Published var isMoveContractPresented = false
    @Published var isChangeTierPresented: ChangeTierContractsInput?
    @Published var isAddonPresented: ChangeAddonInput?
    @Published var isInsuranceEvidencePresented = false
    @Published var isAddonErrorPresented: String?
    let addonErrorRouter = Router()
    @Published var isEuroBonusPresented = false
    @Published var isFaqTopicPresented: FaqTopic?
    @Published var isFaqPresented: FAQModel?
    @Published var askForPushNotification = false

    private var deeplinkToBeOpenedAfterLogin: URL?
    private var cancellables = Set<AnyCancellable>()
    weak var tabBar: UITabBarController? {
        didSet {
            guard #available(iOS 18, *), UIDevice.current.userInterfaceIdiom == .pad else { return }
            tabBar?.traitOverrides.horizontalSizeClass = .compact
        }
    }

    init() {
        pushNotificationHandler.viewModel = self
        deepLinkHandler.viewModel = self
        setupObservers()
        homeNavigationVm.pushToProfile = { [weak self] in
            self?.selectedTab = 4
            self?.profileNavigationVm.pushToProfile()
        }

        EditCoInsuredViewModel.updatedCoInsuredForContractId
            .receive(on: RunLoop.main)
            .delay(for: 1.5, scheduler: RunLoop.main)
            .sink { _ in
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                contractStore.send(.fetchContracts)

                let homeStore: HomeStore = globalPresentableStoreContainer.get()
                homeStore.send(.fetchQuickActions)
            }
            .store(in: &cancellables)

        $selectedTab
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                if self?.selectedTab == self?.previousTab,
                    let nav = self?.tabBar?.selectedViewController?.children
                        .first(where: { $0.isKind(of: UINavigationController.self) }) as? UINavigationController
                {
                    nav.popToRootViewController(animated: true)
                }
            }
            .store(in: &cancellables)
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openDeepLinkNotification),
            name: .openDeepLink,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(registerForPushNotification),
            name: .registerForPushNotifications,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePushNotification),
            name: .handlePushNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(chatClosed), name: .chatClosed, object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addonsChanged),
            name: .addonsChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tierChanged),
            name: .tierChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(claimCreated),
            name: .claimCreated,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openChangeTier),
            name: .openChangeTier,
            object: nil
        )
    }

    @objc func addonsChanged() {
        Task {
            let store: CrossSellStore = globalPresentableStoreContainer.get()
            let contractStore: ContractStore = globalPresentableStoreContainer.get()
            _ = await (
                store.sendAsync(.fetchAddonBanners),
                contractStore.sendAsync(.fetchContracts)
            )
        }
        NotificationCenter.default.post(name: .openCrossSell, object: CrossSellInfo(type: .addon))
    }

    @objc func openChangeTier(notification: Notification) {
        let contractId = notification.object as? String
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        if let contractId, let contract: Contracts.Contract = contractStore.state.contractForId(contractId) {
            isChangeTierPresented = .init(
                source: .betterCoverage,
                contracts: [
                    .init(
                        contractId: contractId,
                        contractDisplayName: contract.currentAgreement?.productVariant.displayName ?? "",
                        contractExposureName: contract.exposureDisplayName
                    )
                ]

            )
        }
    }

    @objc func tierChanged() {
        let crossSellStore: CrossSellStore = globalPresentableStoreContainer.get()
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        Task {
            await (
                crossSellStore.sendAsync(.fetchAddonBanner),
                contractStore.sendAsync(.fetchContracts)
            )
        }
    }

    @objc func openDeepLinkNotification(notification: Notification) {
        if let deepLinkUrl = notification.object as? URL {
            if ApplicationState.currentState == .loggedIn {
                handleDeepLinks(deepLinkUrl: deepLinkUrl)
            } else if !deepLinkUrl.absoluteString.contains("//bankid") {
                deeplinkToBeOpenedAfterLogin = deepLinkUrl
            }
        }
    }

    @objc func claimCreated(notification: Notification) {
        Task { @MainActor in
            let store: ClaimsStore = globalPresentableStoreContainer.get()
            store.send(.fetchActiveClaims)
            let profileStore: ProfileStore = globalPresentableStoreContainer.get()
            if profileStore.state.pushNotificationCurrentStatus() != .authorized {
                askForPushNotification = true
            }
        }
    }

    @objc func registerForPushNotification() {
        Task {
            await UIApplication.shared.appDelegate.registerForPushNotifications()
        }
    }

    @objc func handlePushNotification(notification: Notification) {
        if hasLaunchFinished.value {
            handle(notification: notification)
        } else {
            hasLaunchFinishedCancellable = hasLaunchFinished.filter { $0 }
                .sink { [weak self] _ in
                    self?.handle(notification: notification)
                    self?.hasLaunchFinishedCancellable = nil
                }
        }
    }

    @objc func chatClosed() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        store.send(.fetchChatNotifications)
    }

    private func handle(notification: Notification) {
        pushNotificationHandler.handle(notification)
    }

    func actionAfterLogin() {
        if let deeplinkToBeOpenedAfterLogin {
            handleDeepLinks(deepLinkUrl: deeplinkToBeOpenedAfterLogin)
            self.deeplinkToBeOpenedAfterLogin = nil
        }
    }

    private func handleDeepLinks(deepLinkUrl: URL?) {
        deepLinkHandler.handle(deepLinkUrl)
    }

    func openUrl(url: URL) {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        contractStore.send(.fetchContracts)
        let homeStore: HomeStore = globalPresentableStoreContainer.get()
        homeStore.send(.fetchQuickActions)
        var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if urlComponent?.scheme == nil {
            urlComponent?.scheme = "https"
        }
        let schema = urlComponent?.scheme
        if let finalUrl = urlComponent?.url {
            if schema == "https" || schema == "http" {
                let vc = SFSafariViewController(url: finalUrl)
                vc.modalPresentationStyle = .pageSheet
                vc.preferredControlTintColor = .brand(.primaryText())
                UIApplication.shared.getTopViewController()?.present(vc, animated: true)
            } else {
                if Bundle.main.urlSchemes.contains(schema ?? "") {
                    return
                }
                Dependencies.urlOpener.open(url)
            }
        }
    }

    func handleChangeTier(contractId: String?) {
        pushNotificationHandler.handleChangeTier(contractId: contractId)
    }

    func handleAddon(type: AddonBanner.AddonType, contractId: String?) async {
        await pushNotificationHandler.handleAddon(type: type, contractId: contractId)
    }

    func handleInsuranceEvidence() {
        pushNotificationHandler.handleInsuranceEvidence()
    }

    func handleClaimDetails(claimId: String?) async {
        await pushNotificationHandler.handleClaimDetails(claimId: claimId)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HomeTab: TrackingViewNameProtocol {
    var nameForTracking: String {
        String(describing: HomeScreen.self)
    }
}
