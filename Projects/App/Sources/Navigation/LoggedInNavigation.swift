import Addons
import ChangeTier
import Chat
import Claims
import Combine
import Contracts
import CrossSell
import EditCoInsured
import EditCoInsuredShared
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
    @InjectObservableObject private var features: FeatureFlags
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

            if features.isPaymentScreenEnabled {
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
            .handleEditCoInsured(
                with: vm.travelCertificateNavigationVm.editCoInsuredVm
            )
        }
        .modally(
            presented: $vm.isInsuranceEvidencePresented,
            options: .constant(.alwaysOpenOnTop),
            tracking: nil
        ) {
            InsuranceEvidenceNavigation()
        }
        .modally(
            presented: $vm.isMoveContractPresented,
            options: .constant(.alwaysOpenOnTop)
        ) {
            HandleMoving()
        }
        .modally(
            item: $vm.isChangeTierPresented,
            options: .constant(.alwaysOpenOnTop),
            tracking: nil
        ) { changeTierInput in
            ChangeTierNavigation(input: changeTierInput)
        }
        .modally(
            item: $vm.isAddonPresented,
            options: .constant(.alwaysOpenOnTop),
            tracking: nil
        ) { addonInput in
            ChangeAddonNavigation(input: addonInput)
        }
        .detent(
            item: $vm.isAddonErrorPresented,

            options: .constant([.alwaysOpenOnTop])
        ) { error in
            GenericErrorView(description: error, formPosition: .compact)
                .hStateViewButtonConfig(
                    .init(
                        actionButton: .init(
                            buttonAction: { [weak vm] in
                                vm?.addonErrorRouter.dismiss()
                            }
                        )
                    )
                )
                .embededInNavigation(router: vm.addonErrorRouter, tracking: LoggedInNavigationDetentType.error)
        }
        .handleTerminateInsurance(vm: vm.terminateInsuranceVm) {
            dismissType in
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
            case .changeTierFoundBetterPriceStarted, .changeTierMissingCoverageAndTermsStarted:
                break
            }
        }
        .modally(
            presented: $vm.isEuroBonusPresented,
            options: .constant(.alwaysOpenOnTop)
        ) {
            EuroBonusNavigation(useOwnNavigation: true)
        }
        .detent(
            item: $vm.isFaqTopicPresented,
            transitionType: .detent(style: [.large]),
            options: .constant(.alwaysOpenOnTop)
        ) { topic in
            HelpCenterTopicNavigation(topic: topic)
        }
        .introspect(.tabView, on: .iOS(.v13...)) { tabBar in
            vm.tabBar = tabBar
        }
        .detent(
            item: $vm.isFaqPresented,
            transitionType: .detent(style: [.large]),
            options: .constant(.alwaysOpenOnTop)
        ) { question in
            HelpCenterQuestionNavigation(question: question)
        }
        .introspect(.tabView, on: .iOS(.v13...)) { tabBar in
            vm.tabBar = tabBar
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
                ChangeTierNavigation(input: input) {
                    //added delay since we don't have a terms version at the place right after the insurance has been created
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let store: ContractStore = globalPresentableStoreContainer.get()
                        store.send(.fetchContracts)
                    }
                }
            case let .addon(input: input):
                ChangeAddonNavigation(input: input)
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
                LanguagePickerView {
                    [weak profileNavigationVm = vm.profileNavigationVm, weak mainNavigationVm, weak vm] in
                    //show loading screen since we everything needs to be updated
                    mainNavigationVm?.hasLaunchFinished = false
                    profileNavigationVm?.isLanguagePickerPresented = false
                    let store: ProfileStore = globalPresentableStoreContainer.get()
                    store.send(.updateLanguage)
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
                .embededInNavigation(tracking: ProfileRedirectType.deleteRequestLoading)
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

    var body: some View {
        return RouterHost(router: homeNavigationVm.router, tracking: self) {
            HomeScreen()
                .routerDestination(for: ClaimModel.self, options: [.hidesBottomBarWhenPushed]) { claim in
                    openClaimDetails(claim: claim, type: .claim(id: claim.id))
                }
                .routerDestination(for: String.self) { conversation in
                    InboxView()
                        .configureTitle(L10n.chatConversationInbox)
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
            ClaimsMainNavigation(from: .generic)
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
                                let partners: [Partner] = sickAbroadPartners.compactMap({
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
                                })

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
                        options: .navigationType(type: .large),
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
                    options: .navigationType(type: .large),
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
                        case let .claimDetailForConversationId(id):
                            let claimStore: ClaimsStore = globalPresentableStoreContainer.get()
                            let claim = claimStore.state.claimFromConversation(for: id)
                            openClaimDetails(claim: claim, type: .conversation(id: id))
                        }
                    }
                )
            }
        )
    }

    private func openClaimDetails(claim: ClaimModel?, type: FetchClaimDetailsType) -> some View {
        ClaimDetailView(claim: claim, type: type)
            .configureTitle(L10n.claimsYourClaim)
            .onDeinit {
                Task {
                    let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
                    if claim?.showClaimClosedFlow ?? false {
                        if let claim = claim {
                            NotificationCenter.default.post(name: .openCrossSell, object: claim.asCrossSellInfo)
                            let service: hFetchClaimDetailsClient = Dependencies.shared.resolve()
                            try await service.acknowledgeClosedStatus(claimId: claim.id)
                            claimsStore.send(.fetchClaims)
                        }
                    }
                }
            }
    }
}

private enum LoggedInNavigationDetentType: TrackingViewNameProtocol {
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
    @Published var isChangeTierPresented: ChangeTierContractsInput?
    @Published var isAddonPresented: ChangeAddonInput?
    @Published var isInsuranceEvidencePresented = false
    @Published var isAddonErrorPresented: String?
    let addonErrorRouter = Router()
    @Published var isEuroBonusPresented = false
    @Published var isUrlPresented: URL?
    @Published var isFaqTopicPresented: FaqTopic?
    @Published var isFaqPresented: FAQModel?

    private var deeplinkToBeOpenedAfterLogin: URL?
    private var cancellables = Set<AnyCancellable>()
    weak var tabBar: UITabBarController? {
        didSet {
            guard #available(iOS 18, *), UIDevice.current.userInterfaceIdiom == .pad else { return }
            tabBar?.traitOverrides.horizontalSizeClass = .compact
        }
    }
    init() {
        setupObservers()
        self.homeNavigationVm.pushToProfile = {
            self.selectedTab = 4
            self.profileNavigationVm.pushToProfile()
        }

        EditCoInsuredViewModel.updatedCoInsuredForContractId
            .receive(on: RunLoop.main)
            .delay(for: 1.5, scheduler: RunLoop.main)
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
            selector: #selector(addonAdded),
            name: .addonAdded,
            object: nil
        )
    }

    @objc func addonAdded(notification: Notification) {
        Task {
            let store: CrossSellStore = globalPresentableStoreContainer.get()
            await store.sendAsync(.fetchAddonBanner)
        }
        NotificationCenter.default.post(name: .openCrossSell, object: CrossSellInfo.init(type: .addon))
    }

    @objc func openDeepLinkNotification(notification: Notification) {
        if let deepLinkUrl = notification.object as? URL {
            if ApplicationState.currentState == .loggedIn {
                self.handleDeepLinks(deepLinkUrl: deepLinkUrl)
            } else if !deepLinkUrl.absoluteString.contains("//bankid") {
                self.deeplinkToBeOpenedAfterLogin = deepLinkUrl
            }
        }
    }

    @objc func registerForPushNotification(notification: Notification) {
        Task {
            await UIApplication.shared.appDelegate.registerForPushNotifications()
        }
    }

    @objc func handlePushNotification(notification: Notification) {
        if self.hasLaunchFinished.value == true {
            self.handle(notification: notification)
        } else {
            self.hasLaunchFinishedCancellable = self.hasLaunchFinished.filter({ $0 })
                .sink { [weak self] value in
                    self?.handle(notification: notification)
                    self?.hasLaunchFinishedCancellable = nil
                }
        }
    }

    @objc func chatClosed(notification: Notification) {
        let store: HomeStore = globalPresentableStoreContainer.get()
        store.send(.fetchChatNotifications)
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
            case .CHANGE_TIER:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                let userInfo = notification.userInfo
                let contractId = userInfo?["contractId"] as? String
                handleChangeTier(contractId: contractId)
            case .ADDON_TRAVEL:
                Task {
                    await handleTravelAddon()
                }
            case .OPEN_CLAIM, .CLAIM_CLOSED:
                let userInfo = notification.userInfo
                let claimId = userInfo?["claimId"] as? String
                Task {
                    await handleClaimDetails(claimId: claimId)
                }
            case .INSURANCE_EVIDENCE:
                self.handleInsuranceEvidence()
            case .TRAVEL_CERTIFICATE:
                self.isTravelInsurancePresented = true
            }
        }
    }

    func actionAfterLogin() {
        if let deeplinkToBeOpenedAfterLogin {
            handleDeepLinks(deepLinkUrl: deeplinkToBeOpenedAfterLogin)
            self.deeplinkToBeOpenedAfterLogin = nil
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
                let contractId = url.getParameter(property: .contractId)

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
            case .insuranceEvidence:
                self.handleInsuranceEvidence()
            case .helpCenter:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.homeNavigationVm.isHelpCenterPresented = true
                }
            case .helpCenterTopic:
                if let id = url.getParameter(property: .id) {
                    Task {
                        let store: HomeStore = globalPresentableStoreContainer.get()
                        if store.state.helpCenterFAQModel == nil {
                            await store.sendAsync(.fetchFAQ)
                        }
                        if let helpCenterFAQModel = store.state.helpCenterFAQModel,
                            let topic = helpCenterFAQModel.topics.first(where: { $0.id == id })
                        {
                            isFaqTopicPresented = topic
                        }
                    }
                }
            case .helpCenterQuestion:
                if let id = url.getParameter(property: .id) {
                    Task {
                        let store: HomeStore = globalPresentableStoreContainer.get()
                        if store.state.getAllFAQ()?.first(where: { $0.id == id }) == nil {
                            await store.sendAsync(.fetchFAQ)
                        }
                        if let question = store.state.getAllFAQ()?.first(where: { $0.id == id }) {
                            isFaqPresented = question
                        }
                    }
                }
                break
            case .moveContract:
                self.isMoveContractPresented = true
            case .terminateContract:
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                let contractId = url.getParameter(property: .contractId)
                if let contractId, let contract: Contracts.Contract = contractStore.state.contractForId(contractId) {
                    Task { [weak self] in
                        do {
                            try await Task.sleep(nanoseconds: 200_000_000)
                            let contractsConfig = [contract.asTerminationConfirmConfig]
                            try await self?.terminateInsuranceVm.start(with: contractsConfig)
                        } catch let exception {
                            Toasts.shared.displayToastBar(
                                toast: .init(type: .error, text: exception.localizedDescription)
                            )
                        }
                    }
                } else {
                    Task { [weak self] in
                        do {
                            try await Task.sleep(nanoseconds: 200_000_000)
                            let contractsConfig = contractStore.state.activeContracts
                                .filter({ $0.canTerminate })
                                .map({
                                    $0.asTerminationConfirmConfig
                                })
                            try await self?.terminateInsuranceVm.start(with: contractsConfig)
                        } catch let exception {
                            Toasts.shared.displayToastBar(
                                toast: .init(type: .error, text: exception.localizedDescription)
                            )
                        }
                    }

                }
            case .conversation:
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
            case .chat, .inbox:
                NotificationCenter.default.post(name: .openChat, object: ChatType.inbox)
            case .contactInfo:
                UIApplication.shared.getRootViewController()?.dismiss(animated: true)
                self.selectedTab = 4
                self.profileNavigationVm.pushToProfile()
            case .changeTier:
                let contractId = url.getParameter(property: .contractId)
                handleChangeTier(contractId: contractId)
            case .travelAddon:
                Task {
                    await handleTravelAddon()
                }
            case .editCoInsured:
                handleEditCoInsured(url: url)
            case .claimDetails:
                let claimId = url.getParameter(property: .claimId)
                Task {
                    await self.handleClaimDetails(claimId: claimId)
                }
            case .submitClaim:
                self.selectedTab = 0
                self.homeNavigationVm.isSubmitClaimPresented = true
            case nil:
                let isDeeplink = Environment.current.isDeeplink(url)
                if !isDeeplink {
                    openUrl(url: url)
                }
            }
        }
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

    private func handleChangeTier(contractId: String?) {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        if let contractId, let contract: Contracts.Contract = contractStore.state.contractForId(contractId) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.isChangeTierPresented = .init(
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
                .filter({ $0.supportsChangeTier })
                .map({
                    .init(
                        contractId: $0.id,
                        contractDisplayName: $0.currentAgreement?.productVariant.displayName ?? "",
                        contractExposureName: $0.exposureDisplayName
                    )
                })
            self.isChangeTierPresented = ChangeTierContractsInput(
                source: .changeTier,
                contracts: contractsSupportingChangingTier
            )
        }
    }

    private func handleTravelAddon() async {
        do {
            let client: FetchContractsClient = Dependencies.shared.resolve()
            if let bannerData = try await client.getAddonBannerModel(source: .deeplink) {
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                let addonContracts = bannerData.contractIds.compactMap({
                    contractStore.state.contractForId($0)
                })
                guard !addonContracts.isEmpty else {
                    throw AddonsError.missingContracts
                }
                let addonConfigs: [AddonConfig] = addonContracts.map({
                    .init(
                        contractId: $0.id,
                        exposureName: $0.exposureDisplayName,
                        displayName: $0.currentAgreement?.productVariant.displayName ?? ""
                    )
                })
                self.isAddonPresented = .init(
                    addonSource: .deeplink,
                    contractConfigs: addonConfigs
                )
            }
        } catch {
            isAddonErrorPresented = error.localizedDescription
        }
    }

    private func handleEditCoInsured(url: URL) {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        Task { [weak self] in
            if let contractId = url.getParameter(property: .contractId),
                let contract: Contracts.Contract = contractStore.state.contractForId(contractId)
            {
                let contractConfig: InsuredPeopleConfig = .init(contract: contract, fromInfoCard: false)

                if contract.nbOfMissingCoInsuredWithoutTermination != 0 {
                    self?.homeNavigationVm.editCoInsuredVm
                        .start(
                            fromContract: contractConfig,
                            forMissingCoInsured: true
                        )
                } else {
                    self?.homeNavigationVm.editCoInsuredVm.start(fromContract: contractConfig)
                }
            } else {
                // select insurance
                self?.homeNavigationVm.editCoInsuredVm.start(fromContract: nil)
            }
        }
    }

    private func handleClaimDetails(claimId: String?) async {
        let claimStore: ClaimsStore = globalPresentableStoreContainer.get()
        await claimStore.sendAsync(.fetchClaims)
        if let claimId, let claim = claimStore.state.claim(for: claimId) {
            UIApplication.shared.getRootViewController()?.dismiss(animated: true)
            self.selectedTab = 0
            Task { [weak self] in
                try await Task.sleep(nanoseconds: 200_000_000)
                self?.homeNavigationVm.router.push(claim)
            }
        } else {
            Toasts.shared.displayToastBar(toast: .init(type: .error, text: L10n.General.defaultError))
        }
    }

    private func handleInsuranceEvidence() {
        Task {
            do {
                let profileClient: ProfileClient = Dependencies.shared.resolve()
                let canCreate = try await profileClient.getProfileState().canCreateInsuranceEvidence
                if canCreate {
                    self.isInsuranceEvidencePresented = true
                }
            } catch {

            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HomeTab: TrackingViewNameProtocol {
    var nameForTracking: String {
        return "HomeView"
    }
}
