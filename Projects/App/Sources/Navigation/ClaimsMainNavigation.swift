import Claims
import PresentableStore
import Profile
import SwiftUI
import hCore
import hCoreUI

private class ClaimsMainNavigationViewModel: ObservableObject {
    @Published var isClaimsFlowPresented = false
}

public struct ClaimsMainNavigation: View {
    var from: ClaimsOrigin
    @StateObject var claimsRouter = Router()
    @StateObject private var claimsNavigationVm = ClaimsMainNavigationViewModel()
    @State var shouldHideHonestyPledge = false

    public var body: some View {
        RouterHost(router: claimsRouter, tracking: self) {
            honestyPledge(from: from)
                .onDisappear {
                    let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
                    claimsStore.send(.fetchClaims)
                }
                .hidden($shouldHideHonestyPledge)
                .routerDestination(
                    for: ClaimsRouterActionsWithoutBackButton.self,
                    options: .hidesBackButton
                ) { [weak claimsNavigationVm] destination in
                    if destination == .askForPushNotifications {
                        AskForPushNotifications(
                            text: L10n.claimsActivateNotificationsBody,
                            onActionExecuted: {
                                DispatchQueue.main.async {
                                    claimsNavigationVm?.isClaimsFlowPresented = true
                                }
                            },
                            wrapWithForm: true
                        )
                        .onDisappear {
                            let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
                            claimsStore.send(.fetchClaims)
                        }
                    }
                }
        }
        .modally(
            presented: $claimsNavigationVm.isClaimsFlowPresented
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
        HonestyPledge(onConfirmAction: { [weak claimsNavigationVm, weak claimsRouter] in
            let profileStore: ProfileStore = globalPresentableStoreContainer.get()
            if profileStore.state.pushNotificationCurrentStatus() != .authorized {
                claimsRouter?.push(ClaimsRouterActionsWithoutBackButton.askForPushNotifications)
            } else {
                claimsNavigationVm?.isClaimsFlowPresented = true
            }
        })
    }
}

extension ClaimsMainNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: HonestyPledge.self)

    }

}
