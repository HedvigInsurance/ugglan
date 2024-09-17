import Chat
import Claims
import Combine
import Contracts
import EditCoInsuredShared
import Forever
import Foundation
import Home
import Market
import MoveFlow
import Payment
import PresentableStore
import Profile
import SafariServices
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import TerminateContracts
import TravelCertificate
import hCore
import hCoreUI

struct LoggedInNavigation: View {
    @ObservedObject var vm: LoggedInNavigationViewModel
    @StateObject private var router = Router()
    @StateObject private var foreverRouter = Router()
    @StateObject private var paymentsRouter = Router()
    @EnvironmentObject private var mainNavigationVm: MainNavigationViewModel
    var body: some View {
        TabView(selection: $vm.selectedTab) {
            homeTab
            contractsTab

            let store: ContractStore = globalPresentableStoreContainer.get()
            if !store.state.activeContracts.allSatisfy({ $0.isNonPayingMember })
                || store.state.activeContracts.isEmpty
            {
                foreverTab
            }

            if Dependencies.featureFlags().isPaymentScreenEnabled {
                paymentsTab
            }
            profileTab
        }
        .tint(hTextColor.Opaque.primary)
        .modally(
            presented: $vm.isTravelInsurancePresented,
            options: .constant(.alwaysOpenOnTop)
        ) {
            TravelCertificateNavigation(
                vm: vm.travelCertificateNavigationVm,
                infoButtonPlacement: .leading,
                useOwnNavigation: true
            )
            .handleEditCoInsured(with: vm.travelCertificateNavigationVm.editCoInsuredVm)
        }
        .modally(
            presented: $vm.isMoveContractPresented,
            options: .constant(.alwaysOpenOnTop)
        ) {
            MovingFlowNavigation()
        }
        .handleTerminateInsurance(vm: vm.terminateInsuranceVm) { dismissType in
            switch dismissType {
            case .done:
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                contractStore.send(.fetchContracts)
                let homeStore: HomeStore = globalPresentableStoreContainer.get()
                homeStore.send(.fetchQuickActions)
            case .chat:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                }
            case let .openFeedback(url):
                vm.openUrl(url: url)
            }
        }
        .modally(
            presented: $vm.isEuroBonusPresented,
            options: .constant(.alwaysOpenOnTop)
        ) {
            EuroBonusNavigation(useOwnNavigation: true)
        }
        .introspect(.tabView, on: .iOS(.v13...)) { tabBar in
            vm.tabBar = tabBar
        }
    }

    var homeTab: some View {
        HomeTab(homeNavigationVm: vm.homeNavigationVm, loggedInVm: vm)
            .environmentObject(router)
            .tabItem {
                Image(uiImage: vm.selectedTab == 0 ? hCoreUIAssets.homeTabActive.image : hCoreUIAssets.homeTab.image)
                hText(L10n.tabHomeTitle)
            }
            .tag(0)
    }

    var contractsTab: some View {
        ContractsNavigation(contractsNavigationVm: vm.contractsNavigationVm) { redirectType in
            switch redirectType {
            case .chat:
                ChatScreen(vm: .init(chatService: NewConversationService()))
            case .movingFlow:
                MovingFlowNavigation()
            case let .pdf(document):
                PDFPreview(document: .init(url: document.url, title: document.title))
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
                }
            }
        }
        .handleEditCoInsured(with: vm.contractsNavigationVm.editCoInsuredVm)
        .tabItem {
            Image(
                uiImage: vm.selectedTab == 1
                    ? hCoreUIAssets.contractTabActive.image : hCoreUIAssets.contractTab.image
            )
            hText(L10n.tabInsurancesTitle)
        }
        .tag(1)
    }

    var foreverTab: some View {
        ForeverNavigation(useOwnNavigation: true)
            .environmentObject(foreverRouter)
            .tabItem {
                Image(
                    uiImage: vm.selectedTab == 2 ? hCoreUIAssets.foreverTabActive.image : hCoreUIAssets.foreverTab.image
                )
                hText(L10n.tabReferralsTitle)
            }
            .tag(2)
    }

    var paymentsTab: some View {
        PaymentsNavigation(paymentsNavigationVm: vm.paymentsNavigationVm) { redirectType in
            switch redirectType {
            case .forever:
                ForeverNavigation(useOwnNavigation: false)
                    .hideToolbar()
            case let .openUrl(url):
                EmptyView()
                    .onAppear {
                        vm.openUrl(url: url)
                    }
            }
        }
        .environmentObject(paymentsRouter)
        .tabItem {
            Image(
                uiImage: vm.selectedTab == 3
                    ? hCoreUIAssets.paymentsTabActive.image : hCoreUIAssets.paymentsTab.image
            )
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
                .handleEditCoInsured(with: vm.travelCertificateNavigationVm.editCoInsuredVm)
            case let .deleteAccount(memberDetails):
                let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
                let contractsStore: ContractStore = globalPresentableStoreContainer.get()
                let model = DeleteAccountViewModel(
                    memberDetails: memberDetails,
                    claimsStore: claimsStore,
                    contractsStore: contractsStore
                )

                DeleteAccountView(
                    vm: model,
                    dismissAction: { profileDismissAction in
                        vm.profileNavigationVm.isDeleteAccountPresented = nil
                        switch profileDismissAction {
                        case .openChat:
                            withAnimation {
                                vm.selectedTab = 0
                            }
                            NotificationCenter.default.post(
                                name: .openChat,
                                object: ChatType.newConversation
                            )
                        default:
                            break
                        }
                    }
                )
                .environmentObject(vm.profileNavigationVm)
            case .pickLanguage:
                PickLanguage { [weak profileNavigationVm = vm.profileNavigationVm, weak mainNavigationVm, weak vm] _ in
                    //show loading screen since we everything needs to be updated
                    mainNavigationVm?.hasLaunchFinished = false
                    profileNavigationVm?.isLanguagePickerPresented = false
                    let store: ProfileStore = globalPresentableStoreContainer.get()
                    store.send(.languageChanged)
                    //show home screen with updated langauge
                    mainNavigationVm?.loggedInVm = .init()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        mainNavigationVm?.hasLaunchFinished = true
                        vm?.selectedTab = 0
                    }
                } onCancel: { [weak profileNavigationVm = vm.profileNavigationVm] in
                    profileNavigationVm?.isLanguagePickerPresented = false
                }
            case .deleteRequestLoading:
                DeleteRequestLoadingView(
                    screenState: .success,
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
            }
        }
        .tabItem {
            Image(
                uiImage: vm.selectedTab == 4 ? hCoreUIAssets.profileTabActive.image : hCoreUIAssets.profileTab.image
            )
            hText(L10n.ProfileTab.title)
        }
        .tag(4)
    }
}

struct HomeTab: View {
    @ObservedObject var homeNavigationVm: HomeNavigationViewModel
    @ObservedObject var loggedInVm: LoggedInNavigationViewModel

    var body: some View {
        let claims = Claims()
        return RouterHost(router: homeNavigationVm.router, tracking: self) {
            HomeView(
                claimsContent: claims,
                memberId: {
                    let profileStrore: ProfileStore = globalPresentableStoreContainer.get()
                    return profileStrore.state.memberDetails?.id ?? ""
                }
            )
            .routerDestination(for: ClaimModel.self, options: [.hidesBottomBarWhenPushed]) { claim in
                ClaimDetailView(claim: claim)
                    .environmentObject(homeNavigationVm)
                    .configureTitle(L10n.claimsYourClaim)
            }
            .routerDestination(for: String.self) { conversation in
                InboxView()
                    .configureTitle(L10n.chatConversationInbox)
            }
        }
        .environmentObject(homeNavigationVm)
        .handleConnectPayment(with: homeNavigationVm.connectPaymentVm)
        .handleEditCoInsured(with: homeNavigationVm.editCoInsuredVm)
        .detent(
            presented: $homeNavigationVm.isSubmitClaimPresented,
            style: [.height],
            options: .constant(.withoutGrabber)
        ) {
            ClaimsJourneyMain(from: .generic)
        }
        .detent(
            item: $homeNavigationVm.document,
            style: [.large]
        ) { document in
            if let url = URL(string: document.url) {
                PDFPreview(document: .init(url: url, title: document.displayName))
            }
        }
        .modally(
            presented: $homeNavigationVm.isHelpCenterPresented
        ) {
            HelpCenterNavigation(
                helpCenterVm: loggedInVm.helpCenterVm
            ) { redirectType in
                switch redirectType {
                case .moveFlow:
                    MovingFlowNavigation()
                case .travelInsurance:
                    TravelCertificateNavigation(
                        vm: loggedInVm.travelCertificateNavigationVm,
                        infoButtonPlacement: .leading,
                        useOwnNavigation: true
                    )
                    .handleEditCoInsured(with: loggedInVm.travelCertificateNavigationVm.editCoInsuredVm)
                case .deflect:
                    let model: FlowClaimDeflectStepModel? = {
                        let store: HomeStore = globalPresentableStoreContainer.get()
                        let quickActions = store.state.quickActions
                        if let sickAbroadPartners = quickActions.first(where: { $0.sickAboardPartners != nil })?
                            .sickAboardPartners
                        {
                            return FlowClaimDeflectStepModel(
                                id: .FlowClaimDeflectEmergencyStep,
                                partners: sickAbroadPartners.compactMap({
                                    .init(
                                        id: "",
                                        imageUrl: $0.imageUrl,
                                        url: $0.url,
                                        phoneNumber: $0.phoneNumber
                                    )
                                }),
                                isEmergencyStep: true
                            )
                        }
                        return nil
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
                    .configureTitle(model?.id.title ?? "")
                    .withDismissButton()
                    .embededInNavigation(options: .navigationType(type: .large))
                }
            }
            .handleEditCoInsured(with: loggedInVm.helpCenterVm.editCoInsuredVm)
            .environmentObject(homeNavigationVm)
        }
        .detent(
            presented: $homeNavigationVm.navBarItems.isFirstVetPresented,
            style: [.height]
        ) {
            let store: HomeStore = globalPresentableStoreContainer.get()
            FirstVetView(partners: store.state.quickActions.getFirstVetPartners ?? [])
                .configureTitle(QuickAction.firstVet(partners: []).displayTitle)
                .withDismissButton()
                .embededInNavigation(options: .navigationType(type: .large))
        }
        .detent(
            presented: $homeNavigationVm.navBarItems.isNewOfferPresented,
            style: [.height]
        ) {
            CrossSellingScreen()
                .embededInNavigation(options: .navigationType(type: .large))
        }
        .detent(
            item: $homeNavigationVm.openChat,
            style: [.large],
            options: $homeNavigationVm.openChatOptions,
            content: { openChat in
                ChatNavigation(
                    chatType: openChat.chatType
                ) { type, onDone in
                    AskForPushNotifications(
                        text: L10n.chatActivateNotificationsBody,
                        onActionExecuted: {
                            onDone()
                        }
                    )
                }
            }
        )
    }
}

class LoggedInNavigationViewModel: ObservableObject {
    @Published var selectedTab = 0 {
        willSet {
            self.previousTab = selectedTab
        }
    }
    let hasLaunchFinished = CurrentValueSubject<Bool, Never>(false)
    var hasLaunchFinishedCancellable: AnyCancellable?
    var previousTab: Int = 0

    let contractsNavigationVm = ContractsNavigationViewModel()
    let paymentsNavigationVm = PaymentsNavigationViewModel()
    let profileNavigationVm = ProfileNavigationViewModel()
    let homeNavigationVm = HomeNavigationViewModel()
    let helpCenterVm = HelpCenterNavigationViewModel()
    let travelCertificateNavigationVm = TravelCertificateNavigationViewModel()
    let terminateInsuranceVm = TerminateInsuranceViewModel()

    @Published var isTravelInsurancePresented = false
    @Published var isMoveContractPresented = false
    @Published var isEuroBonusPresented = false
    @Published var isUrlPresented: URL?
    private var openDeepLinkObserver: NSObjectProtocol?
    private var registerForPushNotificationsObserver: NSObjectProtocol?
    private var handlePushNotificationObserver: NSObjectProtocol?
    private var chatClosedObserver: NSObjectProtocol?

    private var cancellables = Set<AnyCancellable>()
    weak var tabBar: UITabBarController?
    init() {
        openDeepLinkObserver = NotificationCenter.default.addObserver(forName: .openDeepLink, object: nil, queue: nil) {
            [weak self] notification in
            let deepLinkUrl = notification.object as? URL
            self?.handleDeepLinks(deepLinkUrl: deepLinkUrl)
        }

        registerForPushNotificationsObserver = NotificationCenter.default.addObserver(
            forName: .registerForPushNotifications,
            object: nil,
            queue: nil
        ) {
            [weak self]
            notification in guard let self = self else { return }
            UIApplication.shared.appDelegate.registerForPushNotifications {}
        }

        handlePushNotificationObserver = NotificationCenter.default.addObserver(
            forName: .handlePushNotification,
            object: nil,
            queue: nil
        ) {
            [weak self]
            notification in
            if self?.hasLaunchFinished.value == true {
                self?.handle(notification: notification)
            } else {
                self?.hasLaunchFinishedCancellable = self?.hasLaunchFinished.filter({ $0 })
                    .sink { value in
                        self?.handle(notification: notification)
                        self?.hasLaunchFinishedCancellable = nil
                    }
            }
        }
        chatClosedObserver = NotificationCenter.default.addObserver(forName: .chatClosed, object: nil, queue: nil) {
            notification in
            let store: HomeStore = globalPresentableStoreContainer.get()
            store.send(.fetchChatNotifications)
        }

        EditCoInsuredViewModel.updatedCoInsuredForContractId
            .receive(on: RunLoop.main)
            .sink { contractId in
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                contractStore.send(.fetchContracts)

                let homeStore: HomeStore = globalPresentableStoreContainer.get()
                homeStore.send(.fetchQuickActions)
            }
            .store(in: &cancellables)

        $selectedTab
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                if self?.selectedTab == self?.previousTab {
                    if let nav = self?.tabBar?.selectedViewController?.children
                        .first(where: { $0.isKind(of: UINavigationController.self) }) as? UINavigationController
                    {
                        nav.popToRootViewController(animated: true)
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func handle(notification: Notification) {
        if let object = notification.object as? PushNotificationType {
            switch object {
            case .NEW_MESSAGE:
                let userInfo = notification.userInfo
                let conversationId = userInfo?["conversationId"] as? String
                NotificationCenter.default.post(
                    name: .openChat,
                    object: ChatType.conversationId(id: conversationId ?? "")
                )
            case .REFERRAL_SUCCESS, .REFERRALS_ENABLED:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 2
            case .CONNECT_DIRECT_DEBIT:
                self.homeNavigationVm.connectPaymentVm.set(for: nil)
            case .PAYMENT_FAILED:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 3
            case .OPEN_FOREVER_TAB:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 2
            case .OPEN_INSURANCE_TAB:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 1
            case .CROSS_SELL:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 1
            case .OPEN_CONTACT_INFO:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 4
                self.profileNavigationVm.pushToProfile()
            }
        }
    }

    private func handleDeepLinks(deepLinkUrl: URL?) {
        if let url = deepLinkUrl {
            let deepLink = DeepLink.getType(from: url)
            switch deepLink {
            case .forever:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 2
            case .directDebit:
                self.homeNavigationVm.connectPaymentVm.set(for: nil)
            case .profile:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 4
            case .insurances:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 1
            case .home:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 0
            case .sasEuroBonus:
                self.isEuroBonusPresented = true
            case .contract:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 1
                let contractId = self.getContractId(from: url)

                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                if let contractId, let contract: Contracts.Contract = contractStore.state.contractForId(contractId) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                        self?.contractsNavigationVm.contractsRouter.popToRoot()
                        self?.contractsNavigationVm.contractsRouter.push(contract)
                    }
                }
            case .payments:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 3
            case .travelCertificate:
                self.isTravelInsurancePresented = true
            case .helpCenter:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.homeNavigationVm.isHelpCenterPresented = true
                }
            case .moveContract:
                self.isMoveContractPresented = true
            case .terminateContract:
                let contractStore: ContractStore = globalPresentableStoreContainer.get()

                let contractsConfig: [TerminationConfirmConfig] = contractStore.state.activeContracts
                    .filter({ $0.canTerminate })
                    .map({
                        $0.asTerminationConfirmConfig
                    })
                self.terminateInsuranceVm.start(with: contractsConfig)
            case .conversation:
                let conversationId = self.getConversationId(from: url)

                Task {
                    let conversationClient: ConversationsClient = Dependencies.shared.resolve()
                    let conversations = try await conversationClient.getConversations()
                    let isValidConversation = conversations.first(where: { $0.id == conversationId })

                    if let conversationId, let isValidConversation {
                        NotificationCenter.default.post(
                            name: .openChat,
                            object: ChatType.conversationId(id: conversationId)
                        )
                    } else {
                        NotificationCenter.default.post(name: .openChat, object: ChatType.inbox)
                    }
                }
            case .chat, .inbox:
                NotificationCenter.default.post(name: .openChat, object: ChatType.inbox)
            case .contactInfo:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 4
                self.profileNavigationVm.pushToProfile()
            case nil:
                openUrl(url: url)
            }
        }
    }

    private func getContractId(from url: URL) -> String? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        return queryItems.first(where: { $0.name == "contractId" })?.value
    }

    private func getConversationId(from url: URL) -> String? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        return queryItems.first(where: { $0.name == "conversationId" })?.value
    }

    public func openUrl(url: URL) {
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
                UIApplication.shared.open(url)
            }
        }
    }

    deinit {
        if let openDeepLinkObserver = openDeepLinkObserver {
            NotificationCenter.default.removeObserver(openDeepLinkObserver)
        }
        if let registerForPushNotificationsObserver = registerForPushNotificationsObserver {
            NotificationCenter.default.removeObserver(registerForPushNotificationsObserver)
        }
        if let handlePushNotificationObserver = handlePushNotificationObserver {
            NotificationCenter.default.removeObserver(handlePushNotificationObserver)
        }
        if let chatClosedObserver = chatClosedObserver {
            NotificationCenter.default.removeObserver(chatClosedObserver)
        }
        NotificationCenter.default.removeObserver(self)
    }
}

extension HomeTab: TrackingViewNameProtocol {
    var nameForTracking: String {
        return "HomeView"
    }
}
