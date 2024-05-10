import Chat
import Claims
import Contracts
import EditCoInsured
import EditCoInsuredShared
import Forever
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

class MainNavigationViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var hasLaunchFinished = false

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hasLaunchFinished = true
        }
    }
}

@main
struct MainNavigationJourney: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var vm = MainNavigationViewModel()
    @StateObject var homeNavigationVm = HomeNavigationViewModel()
    @StateObject var profileNavigationVm = ProfileNavigationViewModel()
    @StateObject var paymentsNavigationVm = PaymentsNavigationViewModel()
    @StateObject var router = Router()
    @StateObject var foreverRouter = Router()
    @StateObject var paymentsRouter = Router()
    var body: some Scene {
        WindowGroup {
            if vm.hasLaunchFinished {
                TabView(selection: $vm.selectedTab) {
                    Group {
                        homeTab
                        contractsTab

                        let store: ContractStore = globalPresentableStoreContainer.get()
                        if !store.state.activeContracts.allSatisfy({ $0.isNonPayingMember })
                            || store.state.activeContracts.isEmpty
                        {
                            foreverTab
                        }

                        //                if Dependencies.featureFlags().isPaymentScreenEnabled {
                        paymentsTab
                        //                }
                        profileTab
                    }
                }
                .tint(hTextColor.primary)
            } else {
                ProgressView()
            }
        }
    }

    var homeTab: some View {
        let claims = Claims()

        return RouterHost(router: router) {
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
        .environmentObject(paymentsNavigationVm)
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
                checkForAlert: checkForAlert
            )
        }
        .detent(
            item: $homeNavigationVm.isEditCoInsuredSelectContractPresented,
            style: .height
        ) { configs in
            EditCoInsuredSelectInsuranceNavigation(
                configs: configs.configs,
                checkForAlert: checkForAlert
            )
        }
        .detent(
            item: $homeNavigationVm.isMissingEditCoInsuredAlertPresented,
            style: .height
        ) { config in
            getMissingCoInsuredAlertView(
                missingContractConfig: config
            )
        }
        .fullScreenCover(
            isPresented: $homeNavigationVm.isHelpCenterPresented
        ) {
            HelpCenterNavigation(redirect: { redirectType in
                switch redirectType {
                case .moveFlow:
                    MovingFlowNavigation()
                case let .editCoInsured(config, _, _):
                    getEditCoInsuredView(config: config)
                case let .editCoInuredSelectInsurance(configs, _):
                    EditCoInsuredSelectInsuranceNavigation(
                        configs: configs,
                        checkForAlert: checkForAlert
                    )
                case let .travelInsurance(redirectType):
                    TravelCertificateNavigation(
                        infoButtonPlacement: .leading,
                        useOwnNavigation: true,
                        openCoInsured: {
                            redirectType(
                                .editCoInsured(config: .init(), showMissingAlert: false, isMissingAlertAction: { _ in })
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
                case .connectPayment:
                    /* TODO: FIX. GET EMPTY VIEW THAT IS NOT DISMISSED */
                    let _ = paymentsNavigationVm.isConnectPaymentPresented = .init(setUpType: .initial)
                }
            })
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
                let options = homeNavigationVm.openChatOptions
                ChatNavigation(openChat: openChat)
            }
        )
        .tabItem {
            Image(uiImage: vm.selectedTab == 0 ? hCoreUIAssets.homeTabActive.image : hCoreUIAssets.homeTab.image)
            hText(L10n.tabHomeTitle)
        }
        .tag(0)
    }

    var contractsTab: some View {
        ContractsNavigation { redirectType in
            switch redirectType {
            case let .editCoInsured(editCoInsuredConfig, _, _):
                getEditCoInsuredView(config: editCoInsuredConfig)
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
        PaymentsNavigation(paymentsNavigationVm: paymentsNavigationVm) { redirectType in
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
        ProfileNavigation(profileNavigationViewModel: profileNavigationVm) { redirectType in
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
                            profileNavigationVm.isEditCoInsuredSelectContractPresented = .init(
                                configs: contractsSupportingCoInsured
                            )
                        } else if let config = contractsSupportingCoInsured.first {
                            profileNavigationVm.isEditCoInsuredPresented = config
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
                        profileNavigationVm.isDeleteAccountPresented = nil
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
                .environmentObject(profileNavigationVm)
            case .pickLanguage:
                PickLanguage { [weak profileNavigationVm, weak vm] _ in
                    //show loading screen since we everything needs to be updated
                    vm?.hasLaunchFinished = false
                    profileNavigationVm?.isLanguagePickerPresented = false

                    //show home screen with updated langauge
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        vm?.hasLaunchFinished = true
                        vm?.selectedTab = 0
                    }
                } onCancel: { [weak profileNavigationVm] in
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
                    checkForAlert: checkForAlert
                )
            case let .editCoInsured(config):
                getEditCoInsuredView(config: config)
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

    @ViewBuilder
    private func getEditCoInsuredView(
        config: InsuredPeopleConfig
    ) -> some View {
        EditCoInsuredNavigation(
            config: config,
            checkForAlert: checkForAlert
        )
    }

    private func getMissingCoInsuredAlertView(
        missingContractConfig: InsuredPeopleConfig
    ) -> some View {
        EditCoInsuredAlertNavigation(
            config: missingContractConfig,
            checkForAlert: checkForAlert
        )
    }

    private func checkForAlert() {
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

#Preview{
    Launch()
}
