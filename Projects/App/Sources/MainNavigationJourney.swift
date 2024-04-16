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
    //    @State private var hasLaunchFinished = false

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
            .sheet(item: $homeNavigationVm.document) { document in
                if let url = URL(string: document.url) {
                    DocumentRepresentable(document: .init(url: url, title: document.displayName))
                        .presentationDetents([.large, .medium])
                }
            }
            .presentModally(
                presented: $homeNavigationVm.isSubmitClaimPresented,
                style: .height,
                content: {
                    HonestyPledge(onConfirmAction: {})
                        .navigationBarTitleDisplayMode(.inline)
                }
            )
            .presentModally(
                presented: $homeNavigationVm.isChatPresented,
                style: .large,
                content: {
                    ChatScreen(vm: .init(topicType: nil))
                }
            )
            .sheet(isPresented: $homeNavigationVm.navBarItems.isFirstVetPresented) {
                let store: HomeStore = globalPresentableStoreContainer.get()
                if let hasVetPartners = store.state.quickActions.getFirstVetPartners {
                    FirstVetView(partners: hasVetPartners)
                        .presentationDetents([.large])
                }
            }
            .sheet(isPresented: $homeNavigationVm.navBarItems.isNewOfferPresented) {
                CrossSellingScreen()
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $homeNavigationVm.isCoInsuredPresented) {
                let contractStore: ContractStore = globalPresentableStoreContainer.get()

                let contractsSupportingCoInsured = contractStore.state.activeContracts
                    .filter({ $0.nbOfMissingCoInsuredWithoutTermination > 0 && $0.showEditCoInsuredInfo })
                    .compactMap({
                        InsuredPeopleConfig(contract: $0, fromInfoCard: true)
                    })

                EditCoInsuredViewJourney(
                    configs: contractsSupportingCoInsured,
                    onDisappear: {
                        homeNavigationVm.isCoInsuredPresented = false
                    }
                )
                .presentationDetents([.large, .medium])
            }
            .sheet(isPresented: $homeNavigationVm.isMissingEditCoInsuredAlertPresented) {
                getMissingCoInsuredAlertView(onDismiss: {
                    homeNavigationVm.isMissingEditCoInsuredAlertPresented = false
                })
            }
            .navigationDestination(for: ClaimModel.self) { claim in
                ClaimDetailView(claim: claim)
                    .environmentObject(homeNavigationVm)
            }
            .fullScreenCover(
                isPresented: $homeNavigationVm.isHelpCenterPresented,
                content: {
                    HelpCenterStartView()
                        .environmentObject(homeNavigationVm)
                }
            )
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
                .sheet(item: $contractsNavigationVm.insurableLimit) { insurableLimit in
                    InfoView(
                        title: L10n.contractCoverageMoreInfo,
                        description: insurableLimit.description,
                        onDismiss: {
                            contractsNavigationVm.insurableLimit = nil
                        }
                    )
                }
                .sheet(
                    item: $contractsNavigationVm.document,
                    onDismiss: {
                        contractsNavigationVm.document = nil
                    }
                ) { document in
                    if let url = URL(string: document.url) {
                        DocumentRepresentable(document: .init(url: url, title: document.displayName))
                            .presentationDetents([.large, .medium])
                    }
                }
                .sheet(item: $contractsNavigationVm.changeYourInformationContract) { contract in
                    EditContract(id: contract.id)
                        .presentationDetents([.medium])
                        .environmentObject(contractsNavigationVm)
                }
                .sheet(isPresented: $contractsNavigationVm.isChatPresented) {
                    ChatScreen(vm: .init(topicType: nil))
                        .presentationDetents([.large, .medium])
                }
                .sheet(
                    item: $contractsNavigationVm.renewalDocument,
                    onDismiss: {
                        contractsNavigationVm.renewalDocument = nil
                    }
                ) { renewalDocument in
                    DocumentRepresentable(document: .init(url: renewalDocument.url, title: renewalDocument.title))
                        .presentationDetents([.large, .medium])
                }
                .sheet(
                    item: $contractsNavigationVm.insuranceUpdate,
                    onDismiss: {
                        contractsNavigationVm.insuranceUpdate = nil
                    }
                ) { insuranceUpdate in
                    UpcomingChangesScreen(
                        updateDate: insuranceUpdate.upcomingChangedAgreement?.activeFrom ?? "",
                        upcomingAgreement: insuranceUpdate.upcomingChangedAgreement
                    )
                    .presentationDetents([.large, .medium])
                }
                .fullScreenCover(item: $contractsNavigationVm.editCoInsuredConfig) { editCoInsuredConfig in
                    EditCoInsuredViewJourney(
                        configs: [editCoInsuredConfig],
                        onDisappear: {
                            contractsNavigationVm.editCoInsuredConfig = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                contractsNavigationVm.isMissingEditCoInsuredAlertPresented = true
                            }
                        }
                    )
                }
                .fullScreenCover(item: $contractsNavigationVm.terminationContract) { contract in
                    let contractConfig: TerminationConfirmConfig = .init(contract: contract)
                    TerminationViewJourney(configs: [contractConfig])
                }
                .fullScreenCover(isPresented: $contractsNavigationVm.isChangeAddressPresented) {
                    MovingFlowViewJourney()
                }
                .sheet(isPresented: $contractsNavigationVm.isMissingEditCoInsuredAlertPresented) {
                    getMissingCoInsuredAlertView(onDismiss: {
                        contractsNavigationVm.isMissingEditCoInsuredAlertPresented = false
                    })
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
    private func getMissingCoInsuredAlertView(onDismiss: @escaping () -> Void) -> some View {
        let store: ContractStore = globalPresentableStoreContainer.get()
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
            let contractConfig = InsuredPeopleConfig(contract: missingContract, fromInfoCard: false)

            EditCoInsuredViewJourney(
                configs: [contractConfig],
                onDisappear: {
                    onDismiss()
                },
                openSpecificScreen: .missingAlert
            )
        }
    }
}
#Preview{
    Launch()
}
