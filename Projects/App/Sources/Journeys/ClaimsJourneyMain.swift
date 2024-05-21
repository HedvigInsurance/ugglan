import Claims
import Presentation
import Profile
import SwiftUI
import hCore
import hCoreUI

private class ClaimsJourneyMainNavigationViewModel: ObservableObject {
    @Published var isClaimsFlowPresented = false
}

public struct ClaimsJourneyMain: View {
    var from: ClaimsOrigin
    @StateObject var claimsRouter = Router()
    @StateObject private var claimsNavigationVm = ClaimsJourneyMainNavigationViewModel()
    @State var shouldHideHonestyPledge = false

    public var body: some View {
        RouterHost(router: claimsRouter) {
            honestyPledge(from: from)
                .onDisappear {
                    let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
                    claimsStore.send(.fetchClaims)
                }
                .hidden($shouldHideHonestyPledge)
                .routerDestination(
                    for: ClaimsRouterActionsWithoutBackButton.self,
                    options: .hidesBackButton
                ) { destination in
                    if destination == .askForPushNotifications {
                        AskForPushnotifications(
                            text: L10n.claimsActivateNotificationsBody,
                            onActionExecuted: {
                                claimsNavigationVm.isClaimsFlowPresented = true
                            }
                        )
                        .hUseOnPush
                    }
                }
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
                claimsRouter.dismiss()
            }
        }
    }

    func honestyPledge(from origin: ClaimsOrigin) -> some View {
        HonestyPledge(onConfirmAction: {
            let profileStore: ProfileStore = globalPresentableStoreContainer.get()
            if profileStore.state.pushNotificationCurrentStatus() != .authorized {
                claimsRouter.push(ClaimsRouterActionsWithoutBackButton.askForPushNotifications)
            } else {
                claimsNavigationVm.isClaimsFlowPresented = true
            }
        })
    }
}
