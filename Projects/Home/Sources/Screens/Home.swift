import Apollo
import Combine
import Flow
import Form
import Foundation
import Presentation
import SafariServices
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct HomeView<Content: View, Claims: View>: View {
    @PresentableStore var store: HomeStore
    @State var toolbarOptionTypes: [ToolbarOptionType] = []
    @StateObject var vm = HomeVM()
    var statusCard: Content?

    var claimsContent: Claims
    var memberId: String

    public init(
        claimsContent: Claims,
        statusCard: (() -> Content)?,
        memberId: @escaping () -> String
    ) {
        self.statusCard = statusCard?()
        self.claimsContent = claimsContent
        self.memberId = memberId()
        let store: HomeStore = globalPresentableStoreContainer.get()
        _toolbarOptionTypes = State(initialValue: store.state.toolbarOptionTypes)
    }
}

extension HomeView {
    func fetch() {
        store.send(.fetchMemberState)
        store.send(.fetchImportantMessages)
        store.send(.fetchCommonClaims)
    }

    public var body: some View {
        hForm {
            centralContent
        }
        .setHomeNavigationBars(
            with: $toolbarOptionTypes,
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
                case .chat:
                    store.send(.openFreeTextChat)
                }
            }
        )
        .onAppear {
            fetch()
            self.toolbarOptionTypes = store.state.toolbarOptionTypes
        }
        .hFormAttachToBottom {
            bottomContent
        }
        .sectionContainerStyle(.transparent)
        .hFormContentPosition(.center)
        .hFormMergeBottomViewWithContentIfNeeded
        .onReceive(store.stateSignal.plain().publisher) { value in
            self.toolbarOptionTypes = value.toolbarOptionTypes
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
                    .slideUpFadeAppearAnimation()
            case .terminated:
                TerminatedSectionView(memberName: memberStateData.name ?? "", claimsContent: claimsContent)
                    .slideUpFadeAppearAnimation()
            case .loading:
                EmptyView()
            }
        }
    }

    private var bottomContent: some View {
        hSection {
            VStack(spacing: 8) {
                switch vm.memberStateData.state {
                case .active:
                    ImportantMessagesView()
                    statusCard
                    deletedInfoView
                    startAClaimButton
                    openOtherServices
                case .future:
                    ImportantMessagesView()
                    FutureSectionInfoView(memberName: vm.memberStateData.name ?? "")
                        .slideUpFadeAppearAnimation()
                case .terminated:
                    deletedInfoView
                    InfoCard(text: L10n.HomeTab.terminatedBody, type: .info)
                    startAClaimButton
                    openOtherServices
                case .loading:
                    EmptyView()
                }
            }
        }
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private var deletedInfoView: some View {
        let members = ApolloClient.retreiveMembersWithDeleteRequests()
        if members.contains(memberId) {
            InfoCard(
                text: L10n.hometabAccountDeletionNotification,
                type: .attention
            )
        }
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
        if hAnalyticsExperiment.homeCommonClaim {
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
    var memberStateDataCancellable: AnyCancellable?

    init() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        memberStateData = store.state.memberStateData
        memberStateDataCancellable = store.stateSignal
            .map({ $0.memberStateData })
            .plain()
            .publisher.receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] value in
                self?.memberStateData = value
            })

    }
}

extension HomeView {
    public static func journey<ResultJourney: JourneyPresentation>(
        claimsContent: Claims,
        memberId: @escaping () -> String,
        @JourneyBuilder resultJourney: @escaping (_ result: HomeResult) -> ResultJourney,
        statusCard: (() -> Content)?
    ) -> some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: HomeView(
                claimsContent: claimsContent,
                statusCard: statusCard,
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
            } else if case let .openCoInsured(contractIds) = action {
                resultJourney(.startCoInsuredFlow(contractIds: contractIds))
            } else if case let .openContractCertificate(url, title) = action {
                Journey(
                    Document(url: url, title: title),
                    style: .detented(.large)
                )
                .withDismissButton
            } else if case .openTravelInsurance = action {
                resultJourney(.openTravelInsurance)
            } else if case .openEmergency = action {
                resultJourney(.openEmergency)
            } else if case let .openCommonClaimDetail(claim, fromOtherService) = action {
                if !fromOtherService {
                    Journey(
                        CommonClaimDetail(claim: claim),
                        style: .detented(.large, modally: true)
                    )
                    .withJourneyDismissButton
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
    case startCoInsuredFlow(contractIds: [String])
    case openEmergency
}

struct Active_Preview: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE

        return HomeView(claimsContent: Text("")) {
            Text("")
        } memberId: {
            "ID"
        }
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
        return HomeView(claimsContent: Text("")) {
            Text("")
        } memberId: {
            "ID"
        }
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
        return HomeView(claimsContent: Text("")) {
            Text("")
        } memberId: {
            "ID"
        }
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
        return HomeView(claimsContent: Text("")) {
            Text("")
        } memberId: {
            "ID"
        }
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
        return HomeView(claimsContent: Text("")) {
            Text("")
        } memberId: {
            "ID"
        }
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
