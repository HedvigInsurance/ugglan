import Apollo
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

//extension NavigationViews {
////    public static let submitClaim = NavigationViews(rawValue: "submitClaim(argument: String)")
//    public static let helpCenter = NavigationViews(rawValue: "helpCenter")
//}

@available(iOS 16.0, *)
public struct HomeView<Claims: View, Content: View>: View {

    @PresentableStore var store: HomeStore
    @StateObject var vm = HomeVM()
    @Inject var featureFlags: FeatureFlags

    private var onNavigation: (Bool) -> Content

    @ObservedObject private var pathState = MyModelObject()  // make stored property?

    var claimsContent: Claims
    var memberId: String

    public init(
        claimsContent: Claims,
        memberId: @escaping () -> String,
        pathState: MyModelObject,
        onNavigation: @escaping (Bool) -> Content
    ) {
        self.claimsContent = claimsContent
        self.memberId = memberId()
        self.pathState = pathState
        self.onNavigation = onNavigation
    }
}

//@available(iOS 16.0, *)
//extension MyModelObject {
//
//    @ViewBuilder
//    func getHomeView(pathState: MyModelObject) -> some View {
//        switch currentHomeRoute {
//        case .helpCenter:
//            HelpCenterStartView()
//        case .submitClaim:
//            pathState.getAppView(pathState: pathState)
//
//        default:
//            EmptyView()
//        }
//    }
//}

@available(iOS 16.0, *)
extension HomeView {
    func fetch() {
        store.send(.fetchMemberState)
        store.send(.fetchImportantMessages)
        store.send(.fetchQuickActions)
        store.send(.fetchChatNotifications)
        store.send(.fetchClaims)
    }

    public var body: some View {
        NavigationStack(path: $pathState.path) {
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
            .navigationDestination(for: NavigationHomeView.self) { view in
                let _ = pathState.changeHomeRoute(view)
                onNavigation(true)
            }
            .navigationDestination(for: NavigationViews.self) { view in
                let _ = pathState.changeRoute(view)  //??
                onNavigation(false)
            }
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
                //                store.send(.startClaim)
                //                pathState.changeRoute(.submitClaim)
            } content: {
                //                NavigationLink(value: NavigationHomeView.submitClaim) {
                NavigationLink(value: NavigationViews.submitClaim) {
                    hText(L10n.HomeTab.claimButtonText)
                }
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
                //                store.send(.openHelpCenter)
            } content: {
                NavigationLink(value: NavigationHomeView.helpCenter) {
                    hText(L10n.HomeTab.getHelp)
                }
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

@available(iOS 16.0, *)
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
                memberId: memberId,
                pathState: .init(),
                onNavigation: { _ in EmptyView() as! Content }
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
            title: L10n.tabHomeTitle,
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

@available(iOS 16.0, *)
struct Active_Preview: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE

        return HomeView<Text, EmptyView>(
            claimsContent: Text(""),
            memberId: {
                "ID"
            },
            pathState: .init(),
            onNavigation: { _ in EmptyView() }
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

@available(iOS 16.0, *)
struct ActiveInFuture_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return HomeView<Text, EmptyView>(
            claimsContent: Text(""),
            memberId: {
                "ID"
            },
            pathState: .init(),
            onNavigation: { _ in EmptyView() }
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

//@available(iOS 16.0, *)
//struct TerminatedToday_Previews: PreviewProvider {
//    static var previews: some View {
//        Localization.Locale.currentLocale = .en_SE
//        return HomeView(
//            claimsContent: Text(""),
//            memberId: {
//                "ID"
//            },
//            pathState: .init()
//        )
//        .onAppear {
//            let store: HomeStore = globalPresentableStoreContainer.get()
//            store.send(
//                .setMemberContractState(
//                    state: .terminated,
//                    contracts: []
//                )
//            )
//            store.send(.setFutureStatus(status: .pendingSwitchable))
//        }
//
//    }
//}

//@available(iOS 16.0, *)
//struct Terminated_Previews: PreviewProvider {
//    static var previews: some View {
//        Localization.Locale.currentLocale = .en_SE
//        return HomeView(
//            claimsContent: Text(""),
//            memberId: {
//                "ID"
//            },
//            pathState: .init()
//        )
//        .onAppear {
//            let store: HomeStore = globalPresentableStoreContainer.get()
//            store.send(
//                .setMemberContractState(
//                    state: .terminated,
//                    contracts: []
//                )
//            )
//            store.send(.setFutureStatus(status: .pendingSwitchable))
//        }
//
//    }
//}

//@available(iOS 16.0, *)
//struct Deleted_Previews: PreviewProvider {
//    static var previews: some View {
//        Localization.Locale.currentLocale = .en_SE
//        return HomeView(
//            claimsContent: Text(""),
//            memberId: {
//                "ID"
//            },
//            pathState: .init()
//        )
//        .onAppear {
//            ApolloClient.saveDeleteAccountStatus(for: "ID")
//            let store: HomeStore = globalPresentableStoreContainer.get()
//            store.send(
//                .setMemberContractState(
//                    state: .active,
//                    contracts: []
//                )
//            )
//            store.send(.setFutureStatus(status: .pendingSwitchable))
//        }
//
//    }
//}
