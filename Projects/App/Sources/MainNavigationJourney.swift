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
    @StateObject var contractsNavigationVm = ContractsNavigationViewModel()
    @StateObject var tabBarControlContext = TabControllerContext()

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

        return NavigationStack(path: $homeNavigationVm.externalNavigationRedirect) {
            HomeView(
                claimsContent: claims,
                memberId: {
                    let profileStrore: ProfileStore = globalPresentableStoreContainer.get()
                    return profileStrore.state.memberDetails?.id ?? ""
                }
            )
            .environmentObject(homeNavigationVm)
            .detent(
                presented: $homeNavigationVm.isSubmitClaimPresented,
                style: .height,
                content: {
                    HonestyPledge(onConfirmAction: {})
                }
            )
            .detent(
                presented: $homeNavigationVm.isChatPresented,
                style: .large,
                content: {
                    ChatScreen(vm: .init(topicType: nil))
                }
            )
            .detent(
                item: $homeNavigationVm.document,
                style: .large
            ) { document in
                if let url = URL(string: document.url) {
                    NavigationStack {
                        PDFPreview(document: .init(url: url, title: document.displayName))
                    }
                }
            }
            .detent(
                presented: $homeNavigationVm.navBarItems.isFirstVetPresented,
                style: .height
            ) {
                let store: HomeStore = globalPresentableStoreContainer.get()
                return FirstVetView(partners: store.state.quickActions.getFirstVetPartners ?? [])
            }
            .detent(
                presented: $homeNavigationVm.navBarItems.isNewOfferPresented,
                style: .height
            ) {
                CrossSellingScreen()
            }
            .detent(
                presented: $homeNavigationVm.isCoInsuredPresented,
                style: .height
            ) {
                let contractStore: ContractStore = globalPresentableStoreContainer.get()

                let contractsSupportingCoInsured = contractStore.state.activeContracts
                    .filter({ $0.showEditCoInsuredInfo })
                    .compactMap({
                        InsuredPeopleConfig(contract: $0, fromInfoCard: true)
                    })

                return EditCoInsuredViewJourney(configs: contractsSupportingCoInsured)
            }
            .navigationDestination(for: ClaimModel.self) { claim in
                ClaimDetailView(claim: claim)
                    .environmentObject(homeNavigationVm)
            }
            .fullScreenCover(isPresented: $homeNavigationVm.isHelpCenterPresented) {
                HelpCenterNavigation()
                    .withClose(for: $homeNavigationVm.isHelpCenterPresented)
                    .environmentObject(homeNavigationVm)
            }
        }
        .tabItem {
            Image(uiImage: vm.selectedTab == 0 ? hCoreUIAssets.homeTabActive.image : hCoreUIAssets.homeTab.image)
            hText(L10n.tabHomeTitle)
        }
        .tag(0)
    }

    var contractsTab: some View {
        return NavigationStack(path: $contractsNavigationVm.externalNavigationRedirect) {
            Contracts(showTerminated: false)
                .environmentObject(contractsNavigationVm)
                .navigationDestination(for: Contract.self) { contract in
                    ContractDetail(id: contract.id, title: contract.currentAgreement?.productVariant.displayName ?? "")
                        .environmentObject(tabBarControlContext)
                        .environmentObject(contractsNavigationVm)
                        .presentationDetents([.medium])
                }
                .detent(
                    item: $contractsNavigationVm.insurableLimit,
                    style: .height
                ) { insurableLimit in
                    InfoView(
                        title: L10n.contractCoverageMoreInfo,
                        description: insurableLimit.description,
                        onDismiss: {
                            contractsNavigationVm.insurableLimit = nil
                        }
                    )
                }
                .detent(
                    item: $contractsNavigationVm.document,
                    style: .height
                ) { document in
                    if let url = URL(string: document.url) {
                        NavigationStack {
                            PDFPreview(document: .init(url: url, title: document.displayName))
                                .onDisappear {
                                    contractsNavigationVm.document = nil
                                }
                        }
                    }
                }
                .detent(
                    item: $contractsNavigationVm.changeYourInformationContract,
                    style: .height
                ) { contract in
                    EditContract(id: contract.id)
                        .presentationDetents([.medium])
                }
                .detent(
                    presented: $contractsNavigationVm.isChatPresented,
                    style: .height
                ) {
                    ChatScreen(vm: .init(topicType: nil))
                        .presentationDetents([.large, .medium])
                }
                .detent(
                    item: $contractsNavigationVm.renewalDocument,
                    style: .height
                ) { renewalDocument in
                    NavigationStack {
                        PDFPreview(document: .init(url: renewalDocument.url, title: renewalDocument.title))
                            .onDisappear {
                                contractsNavigationVm.renewalDocument = nil
                            }
                    }
                }
                .detent(
                    item: $contractsNavigationVm.insuranceUpdate,
                    style: .height
                ) { insuranceUpdate in
                    UpcomingChangesScreen(
                        updateDate: insuranceUpdate.upcomingChangedAgreement?.activeFrom ?? "",
                        upcomingAgreement: insuranceUpdate.upcomingChangedAgreement
                    )
                    .onDisappear {
                        contractsNavigationVm.insuranceUpdate = nil
                    }
                    .presentationDetents([.large, .medium])
                }
                .fullScreenCover(item: $contractsNavigationVm.editCoInsuredConfig) { editCoInsuredConfig in
                    EditCoInsuredViewJourney(configs: [editCoInsuredConfig])
                }
                .fullScreenCover(item: $contractsNavigationVm.terminationContract) { contract in
                    let contractConfig: TerminationConfirmConfig = .init(contract: contract)
                    TerminationViewJourney(configs: [contractConfig])
                }
                .fullScreenCover(isPresented: $contractsNavigationVm.isChangeAddressPresented) {
                    MovingFlowViewJourney()
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
}
#Preview{
    Launch()
}
