import Claims
import PresentableStore
import Profile
import SubmitClaim
import SwiftUI
import hCore
import hCoreUI

private class ClaimsMainNavigationViewModel: ObservableObject {
    @Published var isClaimsFlowPresented = false
}

public struct ClaimsMainNavigation: View {
    @StateObject var claimsRouter = Router()
    @StateObject private var claimsNavigationVm = ClaimsMainNavigationViewModel()
    @State var shouldHideHonestyPledge = false
    @State private var measuredHeight: CGFloat = 0

    public var body: some View {
        RouterHost(router: claimsRouter, tracking: self) {
            honestyPledge()
                .captureHeight(in: $measuredHeight)
                .onDisappear {
                    let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
                    claimsStore.send(.fetchClaims)
                }
                .hidden($shouldHideHonestyPledge)
                .routerDestination(
                    for: SubmitClaimRouterActionsWithoutBackButton.self,
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
                            wrapWithForm: true,
                            height: measuredHeight
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
            SubmitClaimNavigation()
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

    func honestyPledge() -> some View {
        HonestyPledge(onConfirmAction: { [weak claimsNavigationVm, weak claimsRouter] in
            let profileStore: ProfileStore = globalPresentableStoreContainer.get()
            if profileStore.state.pushNotificationCurrentStatus() != .authorized {
                claimsRouter?.push(SubmitClaimRouterActionsWithoutBackButton.askForPushNotifications)
            } else {
                claimsNavigationVm?.isClaimsFlowPresented = true
            }
        })
    }
}

extension ClaimsMainNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: HonestyPledge.self)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

extension View {
    func captureHeight(in binding: Binding<CGFloat>) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { height in
            DispatchQueue.main.async {
                binding.wrappedValue = height
            }
        }
    }
}
