import Apollo
import Chat
import Combine
import Contracts
import Foundation
import Payment
import PresentableStore
import SafariServices
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct HomeView<Claims: View>: View {
    @PresentableStore var store: HomeStore
    @StateObject var vm = HomeVM()
    @Inject var featureFlags: FeatureFlags

    @EnvironmentObject var navigationVm: HomeNavigationViewModel

    var claimsContent: Claims
    var memberId: String

    public init(
        claimsContent: Claims,
        memberId: @escaping () -> String
    ) {
        self.claimsContent = claimsContent
        self.memberId = memberId()
    }
}

extension HomeView {

    public var body: some View {
        hForm {
            centralContent
        }
        .hFormDontUseInitialAnimation
        .setHomeNavigationBars(
            with: $vm.toolbarOptionTypes,
            and: "HomeView",
            action: { type in
                switch type {
                case .newOffer:
                    navigationVm.navBarItems.isNewOfferPresented = true
                case .firstVet:
                    navigationVm.navBarItems.isFirstVetPresented = true
                case .chat, .chatNotification:
                    navigationVm.router.push(String.init(describing: InboxView.self))
                }
            }
        )
        .hFormAttachToBottom {
            VStack(spacing: 0) {
                bottomContent
            }
        }
        .hFormIgnoreKeyboard()
        .sectionContainerStyle(.transparent)
        .hFormContentPosition(.center)
        .hFormMergeBottomViewWithContentIfNeeded
        .onAppear {
            vm.fetch()
        }
    }

    @ViewBuilder
    private var centralContent: some View {
        switch vm.memberContractState {
        case .active:
            ActiveSectionView(
                claimsContent: claimsContent
            )
        case .future:
            hText(L10n.hedvigNameText, style: .heading3)
        case .terminated:
            TerminatedSectionView(claimsContent: claimsContent)
        case .loading:
            EmptyView()
        }
    }

    private var bottomContent: some View {
        hSection {
            VStack(spacing: 0) {
                switch vm.memberContractState {
                case .active:
                    VStack(spacing: 16) {
                        HomeBottomScrollView(memberId: memberId)
                        VStack(spacing: 8) {
                            startAClaimButton
                            openHelpCenter
                        }
                    }
                case .future:
                    VStack(spacing: 16) {
                        HomeBottomScrollView(memberId: memberId)
                        FutureSectionInfoView()
                            .slideUpFadeAppearAnimation()
                        VStack(spacing: 8) {
                            openHelpCenter
                        }
                    }
                case .terminated:
                    VStack(spacing: 16) {
                        HomeBottomScrollView(memberId: memberId)
                        VStack(spacing: 8) {
                            startAClaimButton
                            openHelpCenter
                        }
                    }
                case .loading:
                    VStack(spacing: 8) {
                        openHelpCenter
                    }
                }
            }
        }
        .padding(.bottom, .padding16)
    }

    @ViewBuilder
    private var startAClaimButton: some View {
        if featureFlags.isSubmitClaimEnabled {
            hButton.LargeButton(type: .primary) {
                navigationVm.isSubmitClaimPresented = true
            } content: {
                hText(L10n.HomeTab.claimButtonText)
            }
        }
    }

    @ViewBuilder
    private var openHelpCenter: some View {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        let showHelpCenter =
            !contractStore.state.activeContracts.allSatisfy({ $0.isNonPayingMember })
            || contractStore.state.activeContracts.count == 0
        if showHelpCenter && Dependencies.featureFlags().isHelpCenterEnabled {
            hButton.LargeButton(type: .secondary) {
                navigationVm.isHelpCenterPresented = true
            } content: {
                hText(L10n.HomeTab.getHelp)
            }
        }
    }
}

class HomeVM: ObservableObject {
    @Published var memberContractState: MemberContractState = .loading
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

    func fetch() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        store.send(.fetchMemberState)
        store.send(.fetchImportantMessages)
        store.send(.fetchQuickActions)
        store.send(.fetchChatNotifications)
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        contractStore.send(.fetch)
        let paymentStore: PaymentStore = globalPresentableStoreContainer.get()
        paymentStore.send(.fetchPaymentStatus)
        chatNotificationPullTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
        chatNotificationPullTimerCancellable = chatNotificationPullTimer.receive(on: RunLoop.main)
            .sink { _ in
                let currentVCDescription = UIApplication.shared.getTopVisibleVc()?.debugDescription
                let compareToDescirption = String(describing: HomeView<EmptyView>.self).components(separatedBy: "<")
                    .first
                if currentVCDescription == compareToDescirption {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.fetchChatNotifications)
                }
            }
    }
    private func addObserverForApplicationDidBecomeActive() {
        if ApplicationContext.shared.isLoggedIn {
            NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: OperationQueue.main,
                using: { [weak self] _ in
                    self?.fetch()
                }
            )
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

        return HomeView(
            claimsContent: Text(""),
            memberId: {
                "ID"
            }
        )
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
        return HomeView(
            claimsContent: Text(""),
            memberId: {
                "ID"
            }
        )
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
        return HomeView(
            claimsContent: Text(""),
            memberId: {
                "ID"
            }
        )
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
        return HomeView(
            claimsContent: Text(""),
            memberId: {
                "ID"
            }
        )
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
        return HomeView(
            claimsContent: Text(""),
            memberId: {
                "ID"
            }
        )
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
