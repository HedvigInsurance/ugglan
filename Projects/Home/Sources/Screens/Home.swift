import Apollo
import Combine
import Contracts
import EditCoInsured
import Foundation
import Payment
import Presentation
import SafariServices
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct HomeView<Claims: View>: View {
    @PresentableStore var store: HomeStore
    @StateObject var vm = HomeVM()
    @Inject var featureFlags: FeatureFlags
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
                    store.send(.showNewOffer)
                case .firstVet:
                    if let vetQuickAction = store.state.quickAction.vetQuickAction {
                        store.send(.openQuickActionDetail(quickActions: vetQuickAction, fromOtherServices: false))
                    }
                case .chat, .chatNotification:
                    store.send(.openFreeTextChat(from: nil))
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
    private var centralContent: some View {
        PresentableStoreLens(
            HomeStore.self,
            getter: { state in
                state.memberContractState
            }
        ) { memberContractState in
            switch memberContractState {
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
                store.send(.startClaim)
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
                store.send(.openHelpCenter)
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

extension HomeView {
    public static func journey<ResultJourney: JourneyPresentation>(
        claimsContent: Claims,
        memberId: @escaping () -> String,
        @JourneyBuilder resultJourney: @escaping (_ result: HomeResult) -> ResultJourney
    ) -> some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: HomeView(
                claimsContent: claimsContent,
                memberId: memberId
            ),
            options: [
                .defaults
            ]
        ) { action in
            if case let .openFreeTextChat(type) = action {
                resultJourney(.openFreeTextChat(topic: type))
            } else if case .openHelpCenter = action {
                HelpCenterStartView.journey
            } else if case let .openQuickActionDetail(quickAction, fromOtherService) = action {
                if !fromOtherService {
                    QuickActionDetailScreen.journey(quickAction: quickAction)
                        .withJourneyDismissButton
                        .configureTitle(quickAction.displayTitle)
                }
            } else if case let .openDocument(contractURL) = action {
                Journey(
                    Document(url: contractURL, title: L10n.insuranceCertificateTitle),
                    style: .detented(.large),
                    options: .defaults
                )
            } else if case .startClaim = action {
                resultJourney(.startNewClaim)
            } else if case .showNewOffer = action {
                resultJourney(.openCrossSells)
            } else if case let .openCoInsured(configs) = action {
                resultJourney(.startCoInsuredFlow(configs: configs))
            } else if case let .goToQuickAction(quickAction) = action {
                resultJourney(.goToQuickAction(quickAction: quickAction))
            } else if case let .goToURL(url) = action {
                resultJourney(.goToURL(url: url))
            }
        }
        .configureTabBarItem(
            title: L10n.HomeTab.title,
            image: hCoreUIAssets.homeTab.image,
            selectedImage: hCoreUIAssets.homeTabActive.image
        )
        .configureHomeScroll()
    }
}

public enum HomeResult {
    case openFreeTextChat(topic: ChatTopicType?)
    case startNewClaim
    case openCrossSells
    case startCoInsuredFlow(configs: [InsuredPeopleConfig])
    case goToQuickAction(quickAction: QuickAction)
    case goToURL(url: URL)
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
