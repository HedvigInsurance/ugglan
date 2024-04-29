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
    @StateObject var router = Router()

    var body: some Scene {
        WindowGroup {
            if vm.hasLaunchFinished {
                TabView(selection: $vm.selectedTab) {
                    Group {
                        homeTab
                            .environmentObject(router)
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
        .fullScreenCover(
            item: $homeNavigationVm.isEditCoInsuredFullScreenPresented
        ) { configs in
            EditCoInsuredNavigation(
                configs: configs.configs,
                checkForAlert: {
                    if isMissingContract {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            homeNavigationVm.isMissingEditCoInsuredAlertPresented = configs
                        }
                    }
                }
            )
        }
        .detent(
            item: $homeNavigationVm.isEditCoInsuredDetentPresented,
            style: .height
        ) { configs in
            EditCoInsuredNavigation(
                configs: configs.configs,
                checkForAlert: {
                    if isMissingContract {
                        router.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            homeNavigationVm.isMissingEditCoInsuredAlertPresented = configs
                        }
                    }
                }
            )
        }
        .detent(
            item: $homeNavigationVm.isMissingEditCoInsuredAlertPresented,
            style: .height
        ) { configs in
            getMissingCoInsuredAlertView(missingContractConfigs: configs)
        }
        .fullScreenCover(isPresented: $homeNavigationVm.isHelpCenterPresented) {
            HelpCenterNavigation(redirect: { redirectType in
                switch redirectType {
                case let .editCoInsured(configs, hasMissingAlert, isMissingAlertAction):
                    getEditCoInsuredView(
                        configs: configs,
                        hasMissingAlert: hasMissingAlert,
                        isMissingAlert: isMissingAlertAction
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
                    configs: [editCoInsuredConfig],
                    hasMissingAlert: hasMissingAlert,
                    isMissingAlert: isMissingAlert
                )
            case .chat:
                ChatScreen(vm: .init(topicType: nil))
            case .movingFlow:
                MovingFlowViewJourney()
            case let .pdf(document):
                PDFPreview(document: .init(url: document.url, title: document.title))
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
        configs: [InsuredPeopleConfig],
        hasMissingAlert: Bool,
        isMissingAlert: @escaping (Bool) -> Void
    ) -> some View {
        if hasMissingAlert {
            getMissingCoInsuredAlertView(missingContractConfigs: .init(configs: configs))
        } else {
            EditCoInsuredNavigation(
                configs: configs,
                checkForAlert: {
                    router.dismiss()
                    if isMissingContract {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isMissingAlert(true)
                        }
                    }
                }
            )
        }
    }

    private func getMissingCoInsuredAlertView(
        missingContractConfigs: HomeNavigationViewModel.CoInsuredConfigModel
    ) -> some View {
        EditCoInsuredNavigation(
            configs: missingContractConfigs.configs,
            openSpecificScreen: .missingAlert,
            checkForAlert: {}
        )
    }

    private var isMissingContract: Bool {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        contractStore.send(.fetchContracts)

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
            return true
        }
        return false
    }
}

#Preview{
    Launch()
}
