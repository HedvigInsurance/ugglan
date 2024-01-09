import Apollo
import Combine
import Contracts
import EditCoInsured
import Flow
import Form
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
        store.send(.fetchCommonClaims)
        store.send(.fetchChatNotifications)
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
                    if let claim = store.state.commonClaims.first(where: {
                        $0.id == "30" || $0.id == "31" || $0.id == "32"
                    }) {
                        store.send(.openCommonClaimDetail(commonClaim: claim, fromOtherServices: false))
                    }
                case .chat, .chatNotification:
                    store.send(.openFreeTextChat)
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
                state.memberStateData
            }
        ) { memberStateData in
            switch memberStateData.state {
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
                switch vm.memberStateData.state {
                case .active:
                    VStack(spacing: 16) {
                        HomeBottomScrollView(memberId: memberId)
                        VStack(spacing: 8) {
                            startAClaimButton
                            openOtherServices
                        }
                    }
                case .future:
                    ImportantMessagesView()
                    FutureSectionInfoView(memberName: vm.memberStateData.name ?? "")
                        .slideUpFadeAppearAnimation()
                case .terminated:
                    VStack(spacing: 16) {
                        InfoCard(text: L10n.HomeTab.terminatedBody, type: .info)
                        startAClaimButton
                        openOtherServices
                    }
                case .loading:
                    EmptyView()
                }
            }
        }
        .padding(.bottom, 16)
    }

    private var startAClaimButton: some View {
        hButton.LargeButton(type: .primary) {
            store.send(.startClaim)
        } content: {
            hText(L10n.HomeTab.claimButtonText)
        }
    }

    @ViewBuilder
    private var openOtherServices: some View {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        if !contractStore.state.activeContracts.allSatisfy({ $0.isNonPayingMember }) {
            hButton.LargeButton(type: .ghost) {
                store.send(.openOtherServices)
            } content: {
                hText(L10n.HomeTab.otherServices)
            }
        }
    }
}

class HomeVM: ObservableObject {
    @Published var memberStateData: MemberStateData = .init(state: .loading, name: nil)
    private var cancellables = Set<AnyCancellable>()
    @Published var toolbarOptionTypes: [ToolbarOptionType] = []

    init() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        memberStateData = store.state.memberStateData
        store.stateSignal
            .map({ $0.memberStateData })
            .plain()
            .publisher.receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] value in
                self?.memberStateData = value
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
            if case .openFreeTextChat = action {
                resultJourney(.openFreeTextChat)
            } else if case .openMovingFlow = action {
                resultJourney(.startMovingFlow)
            } else if case .openTravelInsurance = action {
                resultJourney(.openTravelInsurance)
            } else if case .openEmergency = action {
                resultJourney(.openEmergency)
            } else if case .openHelpCenter = action {
                resultJourney(.openHelpCenter)
            } else if case let .openCommonClaimDetail(claim, fromOtherService) = action {
                if !fromOtherService {
                    CommonClaimDetail.journey(claim: claim)
                        .withJourneyDismissButton
                        .configureTitle(claim.displayTitle)
                }
            } else if case .connectPayments = action {
                resultJourney(.openConnectPayments)
            } else if case let .openDocument(contractURL) = action {
                Journey(
                    Document(url: contractURL, title: L10n.insuranceCertificateTitle),
                    style: .detented(.large),
                    options: .defaults
                )
            } else if case .openOtherServices = action {
                OtherService.journey
            } else if case .startClaim = action {
                resultJourney(.startNewClaim)
            } else if case .showNewOffer = action {
                resultJourney(.openCrossSells)
            } else if case let .openCoInsured(configs) = action {
                resultJourney(.startCoInsuredFlow(configs: configs))
            } else if case let .goToQuickAction(quickAction) = action {
                resultJourney(.goToQuickAction(quickAction: quickAction))
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
    case startMovingFlow
    case openFreeTextChat
    case openConnectPayments
    case startNewClaim
    case openTravelInsurance
    case openCrossSells
    case openEmergency
    case openHelpCenter
    case startCoInsuredFlow(configs: [InsuredPeopleConfig])
    case goToQuickAction(quickAction: QuickAction)
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
                    state: .init(state: .active, name: "NAME"),
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
                    state: .init(state: .future, name: "NAME"),
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
                    state: .init(state: .terminated, name: "NAME"),
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
                    state: .init(state: .terminated, name: "NAME"),
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
                    state: .init(state: .active, name: "NAME"),
                    contracts: []
                )
            )
            store.send(.setFutureStatus(status: .pendingSwitchable))
        }

    }
}
