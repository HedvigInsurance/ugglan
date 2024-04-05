import Forever
import Home
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
                    hText("Home")
                }
                .tag(1)

                ForeverView()
                    .tabItem {
                        Image(uiImage: hCoreUIAssets.foreverTab.image)
                        hText("Forever")
                    }
                    .foregroundColor(hTextColor.primary)
                    .accentColor(.black)
            }
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
