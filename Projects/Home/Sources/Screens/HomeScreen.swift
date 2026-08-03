import Apollo
import AppStateContainer
import Chat
import Claims
import Combine
import Contracts
import CrossSell
import Foundation
import Payment
import SafariServices
import SwiftUI
import hCore
import hCoreUI

public struct HomeScreen: View {
    @StateObject var vm = HomeVM()
    @AppObservedObject var homeStore: HomeStore
    @InjectObservableObject var featureFlags: FeatureFlags
    @EnvironmentObject var navigationVm: HomeNavigationViewModel

    public init() {}
}

extension HomeScreen {
    public var body: some View {
        Group {
            switch vm.memberContractState {
            case .active:
                ActiveHomeView()
            case .terminated, .future, .loading:
                legacyHomeForm
            }
        }
        .setHomeNavigationBars(
            with: $homeStore.toolbarOptionTypes,
            action: { [weak navigationVm] type in
                switch type {
                case .crossSell:
                    NotificationCenter.default.post(name: .openCrossSell, object: CrossSellInfo(type: .home))
                case .firstVet:
                    navigationVm?.navBarItems.isFirstVetPresented = true
                case .chat:
                    navigationVm?.router.push(HomeRouterAction.inbox)
                case .travelCertificate, .insuranceEvidence:
                    break
                }
            }
        )
        .trackVisibility(as: HomeScreen.self)
        .task {
            vm.fetchHomeState()
        }
    }

    private var legacyHomeForm: some View {
        hForm {
            centralContent
        }
        .hFormAttachToBottom {
            bottomContent
        }
        .sectionContainerStyle(.transparent)
        .hFormContentPosition(.center)
    }

    @ViewBuilder
    private var centralContent: some View {
        switch vm.memberContractState {
        case .active, .terminated:
            MainHomeView()
        case .future:
            hCoreUIAssets.hedvig.view
                .resizable()
                .scaledToFit()
                .frame(height: 40)
        case .loading:
            EmptyView()
        }
    }

    private var bottomContent: some View {
        hSection {
            VStack(spacing: 0) {
                switch vm.memberContractState {
                case .active, .terminated:
                    VStack(spacing: .padding16) {
                        HomeBottomScrollView()
                        VStack(spacing: .padding8) {
                            startAClaimButton
                            openHelpCenter
                        }
                    }
                case .future:
                    VStack(spacing: .padding16) {
                        HomeBottomScrollView()
                        FutureSectionInfoView()
                            .slideUpFadeAppearAnimation()
                        openHelpCenter
                    }
                case .loading:
                    openHelpCenter
                }
            }
        }
    }

    @ViewBuilder
    private var startAClaimButton: some View {
        if featureFlags.isSubmitClaimEnabled {
            hButton(
                .large,
                .primary,
                content: .init(title: L10n.HomeTab.claimButtonText),
                { [weak navigationVm] in
                    let store: ClaimsStore = globalAppStateContainer.get()
                    navigationVm?.claimsAutomationStartInput = .init(type: store.startClaimType)
                }
            )
        }
    }

    @ViewBuilder
    private var openHelpCenter: some View {
        if !featureFlags.isDemoMode {
            hButton(
                .large,
                .secondary,
                content: .init(title: L10n.HomeTab.getHelp)
            ) { [weak navigationVm] in navigationVm?.isHelpCenterPresented = true }
        }
    }
}

@MainActor
class HomeVM: ObservableObject {
    @Published var memberContractState: MemberContractState = .loading
    private var cancellables = Set<AnyCancellable>()
    private let contractStore: ContractStore = globalAppStateContainer.get()
    private let homeStore: HomeStore = globalAppStateContainer.get()
    private let claimsStore: ClaimsStore = globalAppStateContainer.get()

    init() {
        memberContractState = homeStore.memberContractState
        homeStore.$memberContractState
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] value in
                self?.memberContractState = value
            })
            .store(in: &cancellables)

        addObserverForApplicationDidBecomeActive()
        Task { await homeStore.fetchMissedCharge() }
    }

    func fetchHomeState() {
        Task { await homeStore.fetchMemberState() }
        Task { await homeStore.fetchImportantMessages() }
        Task { await homeStore.fetchQuickActions() }
        Task { await homeStore.fetchChatNotifications() }
        if homeStore.hasMissedCharge {
            Task { await homeStore.fetchMissedCharge() }
        }
        let crossSellStore: CrossSellStore = globalAppStateContainer.get()
        Task { await crossSellStore.fetchRecommendedCrossSellId() }
        Task { await contractStore.fetchContracts() }
        let paymentStore: PaymentStore = globalAppStateContainer.get()
        Task { await paymentStore.fetchPaymentStatus() }

        Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .prepend(.now)
            .receive(on: RunLoop.main)
            .sink { [self] _ in
                guard VisibleScreenTracker.isVisible(HomeScreen.self) else { return }
                Task { await homeStore.fetchChatNotifications() }
            }
            .store(in: &cancellables)

        Timer.publish(every: 120, on: .main, in: .common)
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
            .store(in: &cancellables)
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
}

#Preview("Active") {
    fetchDependenciesForPreview()

    return HomeScreen()
        .onAppear {
            let store: HomeStore = globalAppStateContainer.get()
            store.setMemberContractState(.active, contracts: [])
            store.setFutureStatus(.none)
        }
}

#Preview("ActiveInFuture") {
    fetchDependenciesForPreview()

    return HomeScreen()
        .onAppear {
            ApolloClient.removeDeleteAccountStatus(for: "ID")
            let store: HomeStore = globalAppStateContainer.get()
            store.setMemberContractState(.future, contracts: [])
            store.setFutureStatus(.activeInFuture(inceptionDate: "2023-11-23"))
        }
}

#Preview("TerminatedToday") {
    fetchDependenciesForPreview()

    return HomeScreen()
        .onAppear {
            let store: HomeStore = globalAppStateContainer.get()
            store.setMemberContractState(.terminated, contracts: [])
            store.setFutureStatus(.pendingSwitchable)
        }
}

#Preview("Terminated") {
    fetchDependenciesForPreview()

    return HomeScreen()
        .onAppear {
            let store: HomeStore = globalAppStateContainer.get()
            store.setMemberContractState(.terminated, contracts: [])
            store.setFutureStatus(.pendingSwitchable)
        }
}

#Preview("Deleted") {
    fetchDependenciesForPreview()

    return HomeScreen()
        .onAppear {
            ApolloClient.saveDeleteAccountStatus(for: "ID")
            let store: HomeStore = globalAppStateContainer.get()
            store.setMemberContractState(.active, contracts: [])
            store.setFutureStatus(.pendingSwitchable)
        }
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
