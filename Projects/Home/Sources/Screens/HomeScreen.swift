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
    @Inject var featureFlags: FeatureFlags
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
            action: { type in
                switch type {
                case .newOffer:
                    NotificationCenter.default.post(name: .openCrossSell, object: CrossSellInfo(type: .home))
                case .firstVet:
                    navigationVm.navBarItems.isFirstVetPresented = true
                case .chat, .chatNotification:
                    navigationVm.router.push(String.init(describing: InboxView.self))
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
            hText(L10n.hedvigNameText, style: .heading3)
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
                        VStack(spacing: .padding8) {
                            openHelpCenter
                        }
                    }
                case .loading:
                    VStack(spacing: .padding8) {
                        openHelpCenter
                    }
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
                buttonContent: .init(title: L10n.HomeTab.claimButtonText),
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
            !contractStore.state.activeContracts.allSatisfy({ $0.isNonPayingMember })
            || contractStore.state.activeContracts.count == 0
        if showHelpCenter && featureFlags.isHelpCenterEnabled {
            hButton(
                .large,
                .secondary,
                buttonContent: .init(title: L10n.HomeTab.getHelp),
                {
                    navigationVm.isHelpCenterPresented = true
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
            .map({ $0.memberContractState })
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

    @objc func notification(notification: Notification) {
        Task { [weak self] in
            self?.fetchHomeState()
        }
    }

    private func observeToolbarOptionTypes() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        store.stateSignal
            .map({ $0.toolbarOptionTypes })
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

struct Active_Preview: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)

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
}

struct ActiveInFuture_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
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
}

struct TerminatedToday_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
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
}

struct Terminated_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
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
}

struct Deleted_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
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
}
