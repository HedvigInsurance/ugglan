import Apollo
import AppStateContainer
import Chat
import Claims
import Combine
import Contracts
import CrossSell
import Foundation
import Payment
import SwiftUI
import hCore
import hCoreUI

public struct HomeScreen: View {
    @StateObject var vm = HomeVM()

    public init() {}

    public var body: some View {
        ActiveHomeView()
            .trackVisibility(as: HomeScreen.self)
            .task {
                vm.fetchHomeState()
            }
    }
}

@MainActor
class HomeVM: ObservableObject {
    private var chatNotificationsTimerCancellable: AnyCancellable?
    private var claimsTimerCancellable: AnyCancellable?
    private let contractStore: ContractStore = globalAppStateContainer.get()
    private let homeStore: HomeStore = globalAppStateContainer.get()
    private let claimsStore: ClaimsStore = globalAppStateContainer.get()
    private let crossSellStore: CrossSellStore = globalAppStateContainer.get()
    private let paymentStore: PaymentStore = globalAppStateContainer.get()

    init() {
        addObserverForApplicationDidBecomeActive()
        Task { await homeStore.fetchMissedCharge() }
    }

    func fetchHomeState() {
        Task { await homeStore.fetchMemberState() }
        Task { await homeStore.fetchImportantMessages() }
        Task { await homeStore.fetchQuickActions() }
        Task { await homeStore.fetchOngoingQuotes() }
        if homeStore.hasMissedCharge { Task { await homeStore.fetchMissedCharge() } }
        Task { await homeStore.fetchChatNotifications() }
        Task { await crossSellStore.fetchHomeCrossSells() }
        Task { await crossSellStore.fetchAddonBanners() }
        Task { await contractStore.fetchContracts() }
        Task { await paymentStore.fetchPaymentStatus() }

        chatNotificationsTimerCancellable = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .prepend(.now)
            .receive(on: RunLoop.main)
            .sink { [self] _ in
                guard VisibleScreenTracker.isVisible(HomeScreen.self) else { return }
                Task { await homeStore.fetchChatNotifications() }
            }

        claimsTimerCancellable = Timer.publish(every: 120, on: .main, in: .common)
            .autoconnect()
            .receive(on: RunLoop.main)
            .prepend(.now)
            .sink { [self] _ in
                guard VisibleScreenTracker.isVisible(HomeScreen.self) else { return }
                Task {
                    async let fetchActive = claimsStore.fetchActiveClaims()
                    async let fetchInProgress: Void = claimsStore.fetchClaimInProgress()
                    _ = await (fetchActive, fetchInProgress)
                }
            }
    }

    private func addObserverForApplicationDidBecomeActive() {
        Task {
            let isLoggedIn = await ApplicationContext.shared.isLoggedIn
            if isLoggedIn {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(notification),
                    name: UIApplication.didBecomeActiveNotification,
                    object: nil
                )
            }
        }
    }

    @objc func notification(notification _: Notification) {
        Task { [weak self] in
            self?.fetchHomeState()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

@MainActor private func fetchDependenciesForPreview() {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> HomeClient in HomeClientDemo() })
    Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
    Dependencies.shared.add(module: Module { () -> FetchContractsClient in FetchContractsClientDemo() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in FetchClaimsClientDemo() })
    Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
}

/// The override must land after the demo fetches of `fetchHomeState()`, which would otherwise
/// overwrite it with the demo client's `.active` state.
@MainActor private func previewMemberState(_ state: MemberContractState, _ futureStatus: FutureStatus) {
    Task {
        let store: HomeStore = globalAppStateContainer.get()
        await store.fetchMemberState()
        try? await Task.sleep(seconds: 0.3)
        store.setMemberContractState(state, contracts: [])
        store.setFutureStatus(futureStatus)
    }
}

#Preview("Active") {
    fetchDependenciesForPreview()
    previewMemberState(.active, .none)

    return HomeScreen()
        .environmentObject(HomeNavigationViewModel())
}

#Preview("ActiveInFuture") {
    fetchDependenciesForPreview()
    ApolloClient.removeDeleteAccountStatus(for: "ID")
    previewMemberState(.future, .activeInFuture(inceptionDate: "2023-11-23"))

    return HomeScreen()
        .environmentObject(HomeNavigationViewModel())
}

#Preview("PendingSwitchable") {
    fetchDependenciesForPreview()
    previewMemberState(.future, .pendingSwitchable)

    return HomeScreen()
        .environmentObject(HomeNavigationViewModel())
}

#Preview("PendingNonswitchable") {
    fetchDependenciesForPreview()
    previewMemberState(.future, .pendingNonswitchable)

    return HomeScreen()
        .environmentObject(HomeNavigationViewModel())
}

#Preview("Terminated") {
    fetchDependenciesForPreview()
    previewMemberState(.terminated, .pendingSwitchable)

    return HomeScreen()
        .environmentObject(HomeNavigationViewModel())
}

#Preview("Loading") {
    fetchDependenciesForPreview()
    previewMemberState(.loading, .none)

    return HomeScreen()
        .environmentObject(HomeNavigationViewModel())
}

#Preview("Deleted") {
    fetchDependenciesForPreview()
    ApolloClient.saveDeleteAccountStatus(for: "ID")
    previewMemberState(.active, .pendingSwitchable)

    return HomeScreen()
        .environmentObject(HomeNavigationViewModel())
}

public enum HomeRouterAction: TrackingViewNameProtocol, NavigationTitleProtocol {
    public var navigationTitle: String? {
        L10n.chatConversationInbox
    }

    public var nameForTracking: String {
        String(describing: InboxView.self)
    }

    case inbox
}
