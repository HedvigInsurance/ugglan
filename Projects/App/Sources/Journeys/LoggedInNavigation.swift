import Chat
import Claims
import Contracts
import EditCoInsured
import EditCoInsuredShared
import Forever
import Foundation
import Home
import Market
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
        .tint(hTextColor.primary)
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
            case let .editCoInsured(editCoInsuredConfig, _, _):
                vm.getEditCoInsuredView(config: editCoInsuredConfig)
            case .chat:
                ChatScreen(vm: .init(topicType: nil))
            case .movingFlow:
                MovingFlowNavigation()
            case let .pdf(document):
                PDFPreview(document: .init(url: document.url, title: document.title))
            case let .cancellation(contractConfig):
                TerminationFlowNavigation(
                    configs: [contractConfig],
                    isFlowPresented: { cancelAction in
                        switch cancelAction {
                        case .done:
                            let contractStore: ContractStore = globalPresentableStoreContainer.get()
                            contractStore.send(.fetchContracts)
                            let homeStore: HomeStore = globalPresentableStoreContainer.get()
                            homeStore.send(.fetchQuickActions)
                        case .chat:
                            NotificationCenter.default.post(name: .openChat, object: nil)
                        case let .openFeedback(url):
                            openUrl(url: url)
                        }
                    }
                )
            }
        }
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
                    .toolbar(.hidden, for: .tabBar)
            case let .openUrl(url):
                EmptyView()
                    .onAppear {
                        openUrl(url: url)
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
                    infoButtonPlacement: .trailing,
                    useOwnNavigation: false,
                    openCoInsured: {
                        let contractStore: ContractStore = globalPresentableStoreContainer.get()
                        let contractsSupportingCoInsured = contractStore.state.activeContracts
                            .filter({ $0.showEditCoInsuredInfo })
                            .compactMap({
                                InsuredPeopleConfig(contract: $0, fromInfoCard: true)
                            })
                        if contractsSupportingCoInsured.count > 1 {
                            vm.profileNavigationVm.isEditCoInsuredSelectContractPresented = .init(
                                configs: contractsSupportingCoInsured
                            )
                        } else if let config = contractsSupportingCoInsured.first {
                            vm.profileNavigationVm.isEditCoInsuredPresented = config
                        }
                    }
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
                                object: ChatTopicWrapper(topic: nil, onTop: false)
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

                    //show home screen with updated langauge
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
                            NotificationCenter.default.post(name: .openChat, object: nil)
                        default:
                            vm?.selectedTab = 0
                        }
                    }
                )
            case let .editCoInuredSelectInsurance(configs):
                EditCoInsuredSelectInsuranceNavigation(
                    configs: configs,
                    checkForAlert: vm.checkForAlert
                )
            case let .editCoInsured(config):
                vm.getEditCoInsuredView(config: config)
            default:
                EmptyView()
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

    private func openUrl(url: URL) {
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
                UIApplication.shared.open(url)
            }
        }
    }
}

struct HomeTab: View {
    @ObservedObject var homeNavigationVm: HomeNavigationViewModel
    @ObservedObject var loggedInVm: LoggedInNavigationViewModel
    @StateObject var homeRouter = Router()

    var body: some View {
        let claims = Claims()

        return RouterHost(router: homeRouter) {
            HomeView(
                claimsContent: claims,
                memberId: {
                    let profileStrore: ProfileStore = globalPresentableStoreContainer.get()
                    return profileStrore.state.memberDetails?.id ?? ""
                }
            )
            .routerDestination(for: ClaimModel.self) { claim in
                ClaimDetailView(claim: claim)
                    .environmentObject(homeNavigationVm)
            }
        }
        .environmentObject(homeNavigationVm)
        .handleConnectPayment(with: homeNavigationVm.connectPaymentVm)
        .detent(
            presented: $homeNavigationVm.isSubmitClaimPresented,
            style: .height,
            options: .constant(.withoutGrabber)
        ) {
            ClaimsJourneyMain(from: .generic)
        }
        .detent(
            item: $homeNavigationVm.document,
            style: .large
        ) { document in
            if let url = URL(string: document.url) {
                PDFPreview(document: .init(url: url, title: document.displayName))
                    .embededInNavigation(options: [.navigationType(type: .large)])
            }
        }
        .detent(
            item: $homeNavigationVm.isEditCoInsuredPresented,
            style: .height
        ) { config in
            EditCoInsuredNavigation(
                config: config,
                checkForAlert: loggedInVm.checkForAlert
            )
        }
        .detent(
            item: $homeNavigationVm.isEditCoInsuredSelectContractPresented,
            style: .height
        ) { configs in
            EditCoInsuredSelectInsuranceNavigation(
                configs: configs.configs,
                checkForAlert: loggedInVm.checkForAlert
            )
        }
        .detent(
            item: $homeNavigationVm.isMissingEditCoInsuredAlertPresented,
            style: .height
        ) { config in
            loggedInVm.getMissingCoInsuredAlertView(
                missingContractConfig: config
            )
        }
        .fullScreenCover(
            isPresented: $homeNavigationVm.isHelpCenterPresented
        ) {
            HelpCenterNavigation(
                helpCenterVm: loggedInVm.helpCenterNavigationVm,
                redirect: { redirectType in
                    switch redirectType {
                    case .moveFlow:
                        MovingFlowNavigation()
                    case let .editCoInsured(config, _, _):
                        loggedInVm.getEditCoInsuredView(config: config)
                    case let .editCoInuredSelectInsurance(configs, _):
                        EditCoInsuredSelectInsuranceNavigation(
                            configs: configs,
                            checkForAlert: loggedInVm.checkForAlert
                        )
                    case let .travelInsurance(redirectType):
                        TravelCertificateNavigation(
                            infoButtonPlacement: .leading,
                            useOwnNavigation: true,
                            openCoInsured: {
                                redirectType(
                                    .editCoInsured(
                                        config: .init(),
                                        showMissingAlert: false,
                                        isMissingAlertAction: { _ in }
                                    )
                                )
                            }
                        )
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
                                            url: "",
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
                                    object: ChatTopicWrapper(topic: nil, onTop: true)
                                )
                            }
                        )
                    }
                }
            )
            .environmentObject(homeNavigationVm)
        }
        .detent(
            presented: $homeNavigationVm.navBarItems.isFirstVetPresented,
            style: .height
        ) {
            let store: HomeStore = globalPresentableStoreContainer.get()
            FirstVetView(partners: store.state.quickActions.getFirstVetPartners ?? [])
        }
        .detent(
            presented: $homeNavigationVm.navBarItems.isNewOfferPresented,
            style: .height
        ) {
            CrossSellingScreen()
        }
        .detent(
            item: $homeNavigationVm.openChat,
            style: .large,
            options: $homeNavigationVm.openChatOptions,
            content: { openChat in
                ChatNavigation(openChat: openChat)
            }
        )
    }
}

class LoggedInNavigationViewModel: ObservableObject {
    @Published var selectedTab = 0
    let contractsNavigationVm = ContractsNavigationViewModel()
    let paymentsNavigationVm = PaymentsNavigationViewModel()
    let profileNavigationVm = ProfileNavigationViewModel()
    let homeNavigationVm = HomeNavigationViewModel()
    let helpCenterNavigationVm = HelpCenterNavigationViewModel()

    init() {
        NotificationCenter.default.addObserver(forName: .openDeepLink, object: nil, queue: nil) { notification in
            let deepLinkUrl = notification.object as? URL
            self.handleDeepLinks(deepLinkUrl: deepLinkUrl)
        }
    }

    private func handleDeepLinks(deepLinkUrl: URL?) {
        if let url = deepLinkUrl {
            let deepLink = DeepLink.getType(from: url)
            switch deepLink {
            case .forever:
                UIApplication.shared.getRootViewController()?.presentedViewController?.dismiss(animated: true)
                self.selectedTab = 2
            case .directDebit:
                self.paymentsNavigationVm.connectPaymentVm.connectPaymentModel = .init(setUpType: nil)
            case .profile:
                UIApplication.shared.getRootViewController()?.presentedViewController?.dismiss(animated: true)
                self.selectedTab = 4
            case .insurances:
                UIApplication.shared.getRootViewController()?.presentedViewController?.dismiss(animated: true)
                self.selectedTab = 1
            case .home:
                UIApplication.shared.getRootViewController()?.presentedViewController?.dismiss(animated: true)
                self.selectedTab = 0
            case .sasEuroBonus:
                UIApplication.shared.getRootViewController()?.presentedViewController?.dismiss(animated: true)
                self.selectedTab = 4
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.contractsNavigationVm.contractsRouter.popToRoot()
                    self.profileNavigationVm.profileRouter.push(ProfileRedirectType.euroBonus)
                }
            case .contract:
                UIApplication.shared.getRootViewController()?.presentedViewController?.dismiss(animated: true)
                self.selectedTab = 1
                let contractId = self.getContractId(from: url)

                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                if let contractId, let contract: Contract = contractStore.state.contractForId(contractId) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.contractsNavigationVm.contractsRouter.popToRoot()
                        self.contractsNavigationVm.contractsRouter.push(contract)
                    }
                }
            case .payments:
                UIApplication.shared.getRootViewController()?.presentedViewController?.dismiss(animated: true)
                self.selectedTab = 3
            case .travelCertificate:
                UIApplication.shared.getRootViewController()?.presentedViewController?.dismiss(animated: true)
                self.selectedTab = 0
                /* TODO: NOT SURE IF WE SHOULD REDIRECT TO HELP CENTER HERE? */
                self.homeNavigationVm.isHelpCenterPresented = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.helpCenterNavigationVm.quickActions.isTravelCertificatePresented = true
                }
            case .helpCenter:
                UIApplication.shared.getRootViewController()?.presentedViewController?.dismiss(animated: true)
                self.selectedTab = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.homeNavigationVm.isHelpCenterPresented = true
                }
            case .moveContract:
                /* TODO: NOT SURE IF WE SHOULD REDIRECT TO HELP CENTER HERE? */
                self.homeNavigationVm.isHelpCenterPresented = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.helpCenterNavigationVm.quickActions.isChangeAddressPresented = true
                }
            case .terminateContract:
                /* TODO: NOT SURE IF WE SHOULD REDIRECT TO HELP CENTER HERE? */
                self.homeNavigationVm.isHelpCenterPresented = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.helpCenterNavigationVm.quickActions.isCancellationPresented = true
                }
            case .openChat:
                NotificationCenter.default.post(name: .openChat, object: nil)
            case nil:
                break
            }
        }
    }

    private func getContractId(from url: URL) -> String? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        return queryItems.first(where: { $0.name == "contractId" })?.value
    }

    func checkForAlert() {
        Task {
            homeNavigationVm.isEditCoInsuredPresented = nil
            homeNavigationVm.isEditCoInsuredSelectContractPresented = nil
            homeNavigationVm.isMissingEditCoInsuredAlertPresented = nil
            let contractStore: ContractStore = globalPresentableStoreContainer.get()
            await contractStore.sendAsync(.fetchContracts)
            let missingContract = contractStore.state.activeContracts.first { contract in
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
                let missingContractConfig = InsuredPeopleConfig(contract: missingContract, fromInfoCard: false)
                homeNavigationVm.isMissingEditCoInsuredAlertPresented = missingContractConfig
            }
        }
    }

    @ViewBuilder
    func getEditCoInsuredView(
        config: InsuredPeopleConfig
    ) -> some View {
        EditCoInsuredNavigation(
            config: config,
            checkForAlert: checkForAlert
        )
    }

    func getMissingCoInsuredAlertView(
        missingContractConfig: InsuredPeopleConfig
    ) -> some View {
        EditCoInsuredAlertNavigation(
            config: missingContractConfig,
            checkForAlert: checkForAlert
        )
    }
}
