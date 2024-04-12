import Chat
import Claims
import Contracts
import EditCoInsured
import EditCoInsuredShared
import Forever
import Home
import Payment
import Presentation
import Profile
import SwiftUI
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
            .sheet(isPresented: $homeNavigationVm.isDocumentPresented) {
                if let document = homeNavigationVm.document, let url = URL(string: document.url) {
                    DocumentRepresentable(document: .init(url: url, title: document.displayName))
                        .presentationDetents([.large, .medium])
                }
            }
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
                    .filter({ $0.showEditCoInsuredInfo })
                    .compactMap({
                        InsuredPeopleConfig(contract: $0)
                    })

                EditCoInsuredViewJourney(configs: contractsSupportingCoInsured)
                    .presentationDetents([.large, .medium])
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
        Contracts(showTerminated: false)
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
