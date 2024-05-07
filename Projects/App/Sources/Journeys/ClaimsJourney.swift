import Claims
import Contacts
import Foundation
import Home
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

private class ClaimsJourneyMainNavigationViewModel: ObservableObject {
    @Published var isClaimsFlowPresented = false
}

public struct ClaimsJourneyMain: View {
    var from: ClaimsOrigin
    @StateObject var router = Router()
    @StateObject private var claimsNavigationVm = ClaimsJourneyMainNavigationViewModel()
    @State var shouldHideHonestyPledge = false
    public var body: some View {
        RouterHost(router: router) {
            honestyPledge(from: from)
                .onDisappear {
                    let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
                    claimsStore.send(.fetchClaims)
                }
                .hidden($shouldHideHonestyPledge)
        }
        .fullScreenCover(
            isPresented: $claimsNavigationVm.isClaimsFlowPresented
        ) {
            ClaimsNavigation(origin: from)
                .onAppear {
                    shouldHideHonestyPledge = true
                }
        }
        .onChange(of: claimsNavigationVm.isClaimsFlowPresented) { presented in
            if !presented {
                router.dismiss()
            }
        }
    }

    func honestyPledge(from origin: ClaimsOrigin) -> some View {
        HonestyPledge(onConfirmAction: {
            claimsNavigationVm.isClaimsFlowPresented = true
            /* TODO: ADD PUSH NOTIFICATION */
        })
    }

}

//extension AppJourney {
////    static func claimDetailJourney(claim: ClaimModel) -> some JourneyPresentation {
////        HostingJourney(
////            ClaimsStore.self,
////            rootView: ClaimDetailView(claim: claim)
////        ) { action in
////            if case .closeClaimStatus = action {
////                PopJourney()
////            } else if case let .navigation(navAction) = action {
////                if case let .openFilesFor(claim, files) = navAction {
////                    openFilesFor(claim: claim, files: files)
////                }
////            }
////        }
////        .hidesBottomBarWhenPushed
////    }
//
//    func startClaimsNavigation(from origin: ClaimsOrigin) -> some View {
//        honestyPledge(from: origin)
//    }
//
////    func honestyPledge(from origin: ClaimsOrigin) -> some View {
////        HonestyPledge(onConfirmAction: {
////
////        })
////    }
//}

extension JourneyPresentation {
    func sendActionOnDismiss<S: Store>(_ storeType: S.Type, _ action: S.Action) -> Self {
        return self.onDismiss {
            let store: S = self.presentable.get()

            store.send(action)
        }
    }
}
