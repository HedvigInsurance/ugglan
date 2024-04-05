import Contracts
import Forever
import Home
import Payment
import Presentation
import Profile
import SwiftUI
import hCore
import hCoreUI

@available(iOS 16.0, *)
@main
struct NewApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var pathState = MyModelObject()
    @State private var hasLaunchFinished = false

    @State private var selectedItem = 1

    @ViewBuilder
    func getNavigationView(isHomeNavigation: Bool) -> some View {
        if isHomeNavigation {
            pathState.getHomeView(pathState: pathState)
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

            TabView(selection: $selectedItem) {
                homeTab
                let store: ContractStore = globalPresentableStoreContainer.get()
                if !store.state.activeContracts.allSatisfy({ $0.isNonPayingMember })
                    || store.state.activeContracts.isEmpty
                {
                    foreverTab
                }

                if Dependencies.featureFlags().isPaymentScreenEnabled {
                    paymentsTab
                }
            }
            .foregroundColor(hTextColor.primary)
            .accentColor(.black)
        }
    }

    var homeTab: some View {
        HomeView(
            claimsContent: EmptyView(),
            memberId: {
                return ""
            },
            pathState: pathState,
            onNavigation: { isHomeNavigation in
                return getNavigationView(isHomeNavigation: isHomeNavigation)
            }
        )
        .tabItem {
            Image(uiImage: hCoreUIAssets.homeTab.image)
            hText(L10n.tabHomeTitle)  // hCoreUIAssets.homeTabActive.image
        }
    }

    var contractsTab: some View {
        Contracts(showTerminated: false)
            .tabItem {
                Image(uiImage: hCoreUIAssets.contractTab.image)  // hCoreUIAssets.contractTabActive.image
                hText(L10n.tabInsurancesTitle)
            }
    }

    var foreverTab: some View {
        ForeverView()
            .tabItem {
                Image(uiImage: hCoreUIAssets.foreverTab.image)  // hCoreUIAssets.foreverTabActive.image
                hText(L10n.tabReferralsTitle)
            }
    }

    var paymentsTab: some View {
        PaymentsView()
            .tabItem {
                Image(uiImage: hCoreUIAssets.foreverTab.image)  // hCoreUIAssets.foreverTabActive.image
                hText(L10n.tabPaymentsTitle)
            }
    }

    var profileTab: some View {
        ProfileView()
            .tabItem {
                Image(uiImage: hCoreUIAssets.profileTab.image)  // hCoreUIAssets.profileTabActive.image
                hText(L10n.ProfileTab.title)
            }
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
        default:
            EmptyView()
        }
    }
}

#Preview{
    Launch()
}
