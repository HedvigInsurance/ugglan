import Apollo
import Chat
import Combine
import Contracts
import EditCoInsuredShared
import Foundation
import Payment
import Presentation
import SafariServices
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public class HomeNavigationViewModel: ObservableObject {
    public init() {

        NotificationCenter.default.addObserver(forName: .openChat, object: nil, queue: nil) {
            [weak self] notification in
            if let topicWrapper = notification.object as? ChatTopicWrapper {
                self?.openChatOptions = topicWrapper.onTop ? [.alwaysOpenOnTop, .withoutGrabber] : [.withoutGrabber]
                self?.openChat = topicWrapper
            } else {
                self?.openChatOptions = [.alwaysOpenOnTop, .withoutGrabber]
                self?.openChat = .init(topic: nil, onTop: false)
            }
        }
    }

    @Published public var isFilePresented: FileUrlModel?
    @Published public var isSubmitClaimPresented = false
    @Published public var isHelpCenterPresented = false
    @Published public var isMissingEditCoInsuredAlertPresented: InsuredPeopleConfig?

    // scroll view cards
    @Published public var isEditCoInsuredSelectContractPresented: CoInsuredConfigModel?
    @Published public var isEditCoInsuredPresented: InsuredPeopleConfig?

    @Published public var isConnectPayments = false

    //claim details
    @Published public var document: InsuranceTerm? = nil

    @Published public var navBarItems = NavBarItems()

    @Published public var openChat: ChatTopicWrapper?
    @Published public var openChatOptions: DetentPresentationOption = []

    public struct NavBarItems {
        public var isFirstVetPresented = false
        public var isNewOfferPresented = false
    }

    public struct FileUrlModel: Identifiable {
        public var id: String?
        public var url: URL

        public init(
            url: URL
        ) {
            self.url = url
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

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
    func fetch() {
        store.send(.fetchMemberState)
        store.send(.fetchImportantMessages)
        store.send(.fetchQuickActions)
        store.send(.fetchChatNotifications)
        store.send(.fetchClaims)
    }

    public var body: some View {
        hForm {
            centralContent
        }
        .setHomeNavigationBars(
            with: $vm.toolbarOptionTypes,
            action: { type in
                switch type {
                case .newOffer:
                    navigationVm.navBarItems.isNewOfferPresented = true
                case .firstVet:
                    navigationVm.navBarItems.isFirstVetPresented = true
                case .chat, .chatNotification:
                    NotificationCenter.default.post(name: .openChat, object: ChatTopicWrapper(topic: nil, onTop: false))
                }
            }
        )
        .hFormAttachToBottom {
            VStack(spacing: 0) {
                bottomContent
            }
        }
        .sectionContainerStyle(.transparent)
        .hFormContentPosition(.center)
        .hFormMergeBottomViewWithContentIfNeeded
        .onAppear {
            fetch()
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
            hText(L10n.hedvigNameText, style: .title)
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
                    EmptyView()
                }
            }
        }
        .padding(.bottom, 16)
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
    @Published var toolbarOptionTypes: [ToolbarOptionType] = []

    init() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        memberContractState = store.state.memberContractState
        store.stateSignal
            .map({ $0.memberContractState })
            .plain()
            .publisher.receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] value in
                self?.memberContractState = value
            })
            .store(in: &cancellables)
        toolbarOptionTypes = store.state.toolbarOptionTypes
        addObserverForApplicationDidBecomeActive()
        observeToolbarOptionTypes()
    }

    private func addObserverForApplicationDidBecomeActive() {
        if ApplicationContext.shared.$isLoggedIn.value {
            NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: OperationQueue.main,
                using: { _ in
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    store.send(.fetchChatNotifications)
                    store.send(.fetchClaims)
                }
            )
        }
    }

    private func observeToolbarOptionTypes() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        store.stateSignal
            .map({ $0.toolbarOptionTypes })
            .plain()
            .publisher.receive(on: RunLoop.main)
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
        Localization.Locale.currentLocale = .en_SE

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
        Localization.Locale.currentLocale = .en_SE
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
        Localization.Locale.currentLocale = .en_SE
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
        Localization.Locale.currentLocale = .en_SE
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
        Localization.Locale.currentLocale = .en_SE
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
