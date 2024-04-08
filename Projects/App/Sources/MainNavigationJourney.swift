import Claims
import Contracts
import Forever
import Home
import Payment
import Presentation
import Profile
import SwiftUI
import TravelCertificate
import hCore
import hCoreUI

@available(iOS 16.0, *)
@main
struct MainNavigationJourney: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var pathState = MyModelObject()
    @State private var hasLaunchFinished = false

    @State private var selectedTab = 0

    @ViewBuilder
    func getNavigationView(isHomeNavigation: Bool) -> some View {
        if isHomeNavigation {
            pathState.getHomeView(pathState: pathState)
        } else {
            pathState.getAppView(pathState: pathState)
        }
    }

    @ViewBuilder
    func getNavigationViewFromProfile(isProfileNavigation: Bool) -> some View {
        if isProfileNavigation {
            pathState.getProfileView(pathState: pathState)
        } else {
            pathState.getAppView(pathState: pathState)
        }
    }

    var body: some Scene {
        WindowGroup {
            //            Launch()
            //                .onAppear{
            //                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            //                        hasLaunchFinished = true
            ////                        print("path state: ", pathState.path)
            ////                        pathState.changeRoute(.tabBarView)
            //                    }
            //                }

            //            if hasLaunchFinished {

            TabView(selection: $selectedTab) {
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
        }
    }

    var homeTab: some View {
        let claims = Claims()

        return HomeView(
            claimsContent: claims,
            memberId: {
                return ""
            },
            pathState: pathState,
            onNavigation: { isHomeNavigation in
                return getNavigationView(isHomeNavigation: isHomeNavigation)
            }
        )
        .tabItem {
            Image(uiImage: selectedTab == 0 ? hCoreUIAssets.homeTabActive.image : hCoreUIAssets.homeTab.image)
            hText(L10n.tabHomeTitle)
        }
        .tag(0)
    }

    var contractsTab: some View {
        Contracts(showTerminated: false)
            .tabItem {
                Image(
                    uiImage: selectedTab == 1 ? hCoreUIAssets.contractTabActive.image : hCoreUIAssets.contractTab.image
                )
                hText(L10n.tabInsurancesTitle)
            }
            .tag(1)
    }

    var foreverTab: some View {
        ForeverView()
            .tabItem {
                Image(uiImage: selectedTab == 2 ? hCoreUIAssets.foreverTabActive.image : hCoreUIAssets.foreverTab.image)
                hText(L10n.tabReferralsTitle)
            }
            .tag(2)
    }

    var paymentsTab: some View {
        PaymentsView()
            .tabItem {
                Image(
                    uiImage: selectedTab == 3 ? hCoreUIAssets.paymentsTabActive.image : hCoreUIAssets.paymentsTab.image
                )
                hText(L10n.tabPaymentsTitle)
            }
            .tag(3)
    }

    var profileTab: some View {
        ProfileView(
            pathState: pathState,
            onNavigation: { isProfileNavigation in
                return getNavigationViewFromProfile(isProfileNavigation: isProfileNavigation)
            }
        )
        .tabItem {
            Image(uiImage: selectedTab == 4 ? hCoreUIAssets.profileTabActive.image : hCoreUIAssets.profileTab.image)
            hText(L10n.ProfileTab.title)
        }
        .tag(4)
    }
}

@available(iOS 16.0, *)
extension MyModelObject {
    @ViewBuilder
    func getHomeView(pathState: MyModelObject) -> some View {
        switch currentHomeRoute {
        case .helpCenter:
            HelpCenterStartView()
        }
    }

    @ViewBuilder
    func getAppView(pathState: MyModelObject) -> some View {
        switch currentMainRoute {
        case .submitClaim:
            let _ = pathState.changeClaimsRoute(.honestyPledge)
            getClaimsView(pathState: pathState)
        case .travelCertificate:
            let _ = pathState.changeRoute(.homeView)
            let _ = pathState.changeTravelCertificateRoute(.showList)
            getTravelCertificateView(pathState: pathState)
        default:
            EmptyView()
        }
    }
}

#Preview{
    Launch()
}
