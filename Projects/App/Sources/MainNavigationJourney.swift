import Chat
import Claims
import Contracts
import EditCoInsured
import EditCoInsuredShared
import Forever
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
    @StateObject var homeRouter = Router()

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
        .detent(
            presented: $homeNavigationVm.isSubmitClaimPresented,
            style: .height
        ) {
            HonestyPledge(onConfirmAction: {})
                .embededInNavigation()
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
        .modally(
            item: $homeNavigationVm.isEditCoInsuredPresented
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
        .modally(presented: $homeNavigationVm.isHelpCenterPresented) {
            HelpCenterNavigation(redirect: { redirectType in
                switch redirectType {
                case .moveFlow:
                    MovingFlowNavigation()
                case let .editCoInsured(config, hasMissingAlert, isMissingAlertAction):
                    getEditCoInsuredView(
                        config: config,
                        hasMissingAlert: hasMissingAlert,
                        isMissingAlert: isMissingAlertAction
                    )
                case let .editCoInuredSelectInsurance(configs, isMissingAlertAction):
                    EditCoInsuredSelectInsuranceNavigation(
                        configs: configs,
                        checkForAlert: checkForAlert
                    )
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
                ChatScreen(vm: .init(topicType: openChat.topic))
                    .navigationTitle(L10n.chatTitle)
                    .embededInNavigation()
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
            case let .editCoInsured(editCoInsuredConfig, hasMissingAlert, isMissingAlert):
                getEditCoInsuredView(
                    config: editCoInsuredConfig,
                    hasMissingAlert: hasMissingAlert,
                    isMissingAlert: isMissingAlert
                )
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
                        router.dismiss()
                        switch cancelAction {
                        case .none:
                            break
                        case .chat:
                            NotificationCenter.default.post(name: .openChat, object: nil)
                        case .openFeedback(let url):
                            // TODO: move somewhere else. Also not working
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
        ForeverView()
            .tabItem {
                Image(
                    uiImage: vm.selectedTab == 2 ? hCoreUIAssets.foreverTabActive.image : hCoreUIAssets.foreverTab.image
                )
                hText(L10n.tabReferralsTitle)
            }
            .tag(2)
    }

    var paymentsTab: some View {
        PaymentsView()
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
        ProfileView()
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
        config: InsuredPeopleConfig,
        hasMissingAlert: Bool,
        isMissingAlert: @escaping (InsuredPeopleConfig) -> Void
    ) -> some View {
        if hasMissingAlert {
            getMissingCoInsuredAlertView(
                missingContractConfig: config
            )
        } else {
            EditCoInsuredNavigation(
                config: config,
                checkForAlert: checkForAlert
            )
        }
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
}

#Preview{
    Launch()
}
