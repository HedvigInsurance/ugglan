import Apollo
import Chat
import Claims
import Combine
import Contracts
import CrossSell
import Foundation
import Payment
import PresentableStore
import SafariServices
import SwiftUI
import hCore
import hCoreUI

public struct HomeScreen: View {
    @StateObject var vm = HomeVM()
    @InjectObservableObject var featureFlags: FeatureFlags
    @EnvironmentObject var navigationVm: HomeNavigationViewModel

    public init() {}
}

extension HomeScreen {
    public var body: some View {
        hForm {
            centralContent
        }
        .setHomeNavigationBars(
            with: $vm.toolbarOptionTypes,
            and: "HomeView",
            action: { [weak navigationVm] type in
                switch type {
                case .newOffer, .newOfferNotification:
                    NotificationCenter.default.post(name: .openCrossSell, object: CrossSellInfo(type: .home))
                case .firstVet:
                    navigationVm?.navBarItems.isFirstVetPresented = true
                case .chat, .chatNotification:
                    navigationVm?.router.push(HomeRouterAction.inbox)
                case .travelCertificate, .insuranceEvidence:
                    break
                }
            }
        )
        .hFormAttachToBottom {
            bottomContent
        }
        .sectionContainerStyle(.transparent)
        .hFormContentPosition(.center)
        .onAppear {
            vm.fetchHomeState()
        }
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
                        HomeBottomScrollView(vm: vm.homeBottomScrollViewModel)
                        VStack(spacing: .padding8) {
                            startAClaimButton
                            openHelpCenter
                        }
                    }
                case .future:
                    VStack(spacing: .padding16) {
                        HomeBottomScrollView(vm: vm.homeBottomScrollViewModel)
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
                {
                    navigationVm.isSubmitClaimPresented = true
                }
            )
        }
    }

    @ViewBuilder
    private var openHelpCenter: some View {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        let showHelpCenter =
            !contractStore.state.activeContracts.allSatisfy(\.isNonPayingMember)
            || contractStore.state.activeContracts.count == 0
        if showHelpCenter, featureFlags.isHelpCenterEnabled {
            hButton(
                .large,
                .secondary,
                content: .init(title: L10n.HomeTab.getHelp),
                { [weak navigationVm] in
                    navigationVm?.isHelpCenterPresented = true
                }
            )
        }
    }
}

@MainActor
class HomeVM: ObservableObject {
    @Published var memberContractState: MemberContractState = .loading
    let homeBottomScrollViewModel = HomeBottomScrollViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var chatNotificationPullTimerCancellable: AnyCancellable?
    @Published var toolbarOptionTypes: [ToolbarOptionType] = []
    private var chatNotificationPullTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    init() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        memberContractState = store.state.memberContractState
        store.stateSignal
            .map(\.memberContractState)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] value in
                self?.memberContractState = value
            })
            .store(in: &cancellables)

        toolbarOptionTypes = store.state.toolbarOptionTypes
        addObserverForApplicationDidBecomeActive()
        observeToolbarOptionTypes()
    }

    func fetchHomeState() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        store.send(.fetchMemberState)
        store.send(.fetchImportantMessages)
        store.send(.fetchQuickActions)
        store.send(.fetchChatNotifications)
        let crossSellStore: CrossSellStore = globalPresentableStoreContainer.get()
        crossSellStore.send(.fetchRecommendedCrossSellId)
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        contractStore.send(.fetchContracts)
        let paymentStore: PaymentStore = globalPresentableStoreContainer.get()
        paymentStore.send(.fetchPaymentStatus)
        chatNotificationPullTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
        chatNotificationPullTimerCancellable = chatNotificationPullTimer.receive(on: RunLoop.main)
            .sink { _ in
                let currentVCDescription = UIApplication.shared.getTopVisibleVc()?.debugDescription
                let compareToDescirption = String(describing: HomeScreen.self)
                if currentVCDescription == compareToDescirption {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.fetchChatNotifications)
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

    private func observeToolbarOptionTypes() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        store.stateSignal
            .map(\.toolbarOptionTypes)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] value in
                self?.toolbarOptionTypes = value
            })
            .store(in: &cancellables)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

@MainActor private func fetchDependenciesForPreview() {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> HomeClient in HomeClientDemo() })
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
            let store: HomeStore = globalPresentableStoreContainer.get()
            store.send(
                .setMemberContractState(
                    state: .active,
                    contracts: []
                )
            )
            store.send(.setFutureStatus(status: .none))
        }
}

#Preview("ActiveInFuture") {
    fetchDependenciesForPreview()

    return HomeScreen()
        .onAppear {
            ApolloClient.removeDeleteAccountStatus(for: "ID")
            let store: HomeStore = globalPresentableStoreContainer.get()
            store.send(
                .setMemberContractState(
                    state: .future,
                    contracts: []
                )
            )
            store.send(.setFutureStatus(status: .activeInFuture(inceptionDate: "2023-11-23")))
        }
}

#Preview("TerminatedToday") {
    fetchDependenciesForPreview()

    return HomeScreen()
        .onAppear {
            let store: HomeStore = globalPresentableStoreContainer.get()
            store.send(
                .setMemberContractState(
                    state: .terminated,
                    contracts: []
                )
            )
            store.send(.setFutureStatus(status: .pendingSwitchable))
        }
}

#Preview("Terminated") {
    fetchDependenciesForPreview()

    return HomeScreen()
        .onAppear {
            let store: HomeStore = globalPresentableStoreContainer.get()
            store.send(
                .setMemberContractState(
                    state: .terminated,
                    contracts: []
                )
            )
            store.send(.setFutureStatus(status: .pendingSwitchable))
        }
}

#Preview("Deleted") {
    fetchDependenciesForPreview()

    return HomeScreen()
        .onAppear {
            ApolloClient.saveDeleteAccountStatus(for: "ID")
            let store: HomeStore = globalPresentableStoreContainer.get()
            store.send(
                .setMemberContractState(
                    state: .active,
                    contracts: []
                )
            )
            store.send(.setFutureStatus(status: .pendingSwitchable))
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
