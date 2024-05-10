import Claims
import Presentation
import SwiftUI
import hCoreUI

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
