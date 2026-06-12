import Addons
import AppStateContainer
import Combine
import CrossSell
import Foundation
import SwiftUI
import hCore
import hCoreUI

struct ContractTable: View {
    @AppObservedObject var store: ContractStore
    let showTerminated: Bool
    @State var onlyTerminatedInsurances = false
    @State var bottomContentHeights: [String: CGFloat] = [:]
    @State var cardHeights: [String: CGFloat] = [:]
    @StateObject var vm = ContractTableViewModel()
    @State private var cardDrawRotation = false
    @State private var didMemberExpandCards = false
    @State private var scrollToCardId: String?
    @EnvironmentObject var contractsNavigationVm: ContractsNavigationViewModel
    @EnvironmentObject var router: NavigationRouter
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    private var isExpanded: Bool {
        if voiceOverEnabled {
            return true
        }
        return didMemberExpandCards
    }
    @InjectObservableObject private var featureFlags: FeatureFlags

    private var contractsToShow: [Contract] {
        if showTerminated {
            return store.terminatedContracts
        } else {
            let activeContractsToShow = store.activeContracts
            let pendingContractsToShow = store.pendingContracts
            if !(activeContractsToShow + pendingContractsToShow).isEmpty {
                DispatchQueue.main.async {
                    onlyTerminatedInsurances = false
                }
                return activeContractsToShow + pendingContractsToShow
            } else {
                DispatchQueue.main.async {
                    onlyTerminatedInsurances = true
                }
                return store.terminatedContracts
            }
        }
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack(spacing: .padding8) {
                successView
                    .loadingWithButtonLoading($vm.viewState)
                    .hStateViewButtonConfig(
                        .init(
                            actionButton: .init(buttonAction: {
                                Task { await store.fetchContracts() }
                            }),
                            dismissButton: nil
                        )
                    )
                if !showTerminated {
                    VStack(spacing: .padding8) {
                        CrossSellingView(withHeader: true)
                            .padding(.top, .padding8)

                        addonBannersView

                        movingToANewHomeView
                        if !(store.terminatedContracts.isEmpty || onlyTerminatedInsurances) {
                            hSection {
                                hButton(
                                    .large,
                                    .secondary,
                                    content: .init(
                                        title: L10n.InsurancesTab.cancelledInsurancesLabel(
                                            "\(store.terminatedContracts.count)"
                                        )
                                    ),
                                    {
                                        router.push(ContractsRouterType.terminatedContracts)
                                    }
                                )
                                .hCustomButtonView {
                                    hRow {
                                        HStack {
                                            hText(
                                                L10n.InsurancesTab.cancelledInsurancesLabel(
                                                    "\(store.terminatedContracts.count)"
                                                )
                                            )
                                            .foregroundColor(hTextColor.Opaque.primary)
                                            Spacer()
                                        }
                                    }
                                    .withChevronAccessory
                                    .verticalPadding(0)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                                }
                            }
                            .transition(.slide)
                            .sectionContainerStyle(.transparent)
                        }
                    }
                    .animation(.spring(), value: store.terminatedContracts)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isExpanded)
            .onChange(of: contractsNavigationVm.isActiveTab) { isActive in
                if !isActive {
                    didMemberExpandCards = false
                }
            }
            .onChange(of: isExpanded) { expanded in
                withAnimation(.easeIn(duration: 0.2)) {
                    cardDrawRotation = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeOut(duration: 0.1)) {
                        cardDrawRotation = false
                    }
                }
                if expanded, let cardId = scrollToCardId {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            scrollProxy.scrollTo(cardId, anchor: .bottom)
                        }
                        scrollToCardId = nil
                    }
                }
            }
        }
        .onAppear {
            Task {
                await vm.getAddonBanners()
            }
        }
    }

    private var successView: some View {
        hSection {
            let contracts = contractsToShow
            VStack(spacing: isExpanded ? .padding8 : 0) {
                ForEach(Array(contracts.enumerated()), id: \.element.id) { index, contract in
                    let cumulativeOffset: CGFloat =
                        isExpanded
                        ? 0
                        : contracts.prefix(index + 1).dropFirst()
                            .reduce(0) { sum, c in
                                let height = cardHeights[c.id] ?? 200
                                let peek = (bottomContentHeights[c.id] ?? 0)
                                return sum - (height - peek)
                            }
                    ContractRow(
                        image: contract.pillowType?.bgImage,
                        terminationMessage: contract.terminationMessage,
                        contractDisplayName: contract.currentAgreement?.productVariant.displayName
                            ?? "",
                        contractExposureName: contract.exposureDisplayName,
                        activeFrom: contract.upcomingChangedAgreement?.agreementDate.activeFrom,
                        activeInFuture: contract.activeInFuture,
                        masterInceptionDate: contract.masterInceptionDate,
                        tierDisplayName: contract.currentAgreement?.productVariant.displayNameTier,
                        onClick: {
                            router.push(contract)
                        },
                        onBottomContentHeightChange: { height in
                            bottomContentHeights[contract.id] = height
                        }
                    )
                    .contractCardTruncate(to: !isExpanded)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onReceive(Just(geo.size.height)) { height in
                                    cardHeights[contract.id] = height
                                }
                        }
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .scaleEffect(cardDrawRotation && index > 0 ? (isExpanded ? 0.99 : 1.01) : 1)
                    .zIndex(Double(-index))
                    .offset(y: cumulativeOffset)
                    .transition(.slide)
                    .id(contract.id)
                    .overlay(
                        Group {
                            if !isExpanded && index > 0 {
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        scrollToCardId = contract.id
                                        didMemberExpandCards = true
                                    }
                                    .offset(y: cumulativeOffset)
                                    .accessibilityAddTraits(.isButton)
                            }
                        }
                        .accessibilityHidden(true)
                    )
                }
            }
            .padding(
                .bottom,
                isExpanded
                    ? 0
                    : contracts.dropFirst()
                        .reduce(0) { sum, c in
                            let height = cardHeights[c.id] ?? 200
                            let peek = (bottomContentHeights[c.id] ?? 0)
                            return sum - (height - peek)
                        }
            )
            .animation(.spring(), value: contracts)
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private var addonBannersView: some View {
        if !vm.addonBanners.isEmpty {
            hSection {
                VStack(spacing: .padding8) {
                    ForEach(vm.addonBanners, id: \.self) { banner in
                        let contractInfo = store.getAddonContractInfosFor(contractIds: banner.contractIds)
                        let input = ChangeAddonInput(addonSource: .insurances, contractInfos: contractInfo)

                        AddonCardView(
                            openAddon: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    contractsNavigationVm.isAddonPresented = input
                                }
                            },
                            addon: banner
                        )
                        .hButtonIsLoading(
                            contractsNavigationVm.isAddonPresented?.contractInfos == input.contractInfos
                        )
                    }
                }
            }
            .withHeader(title: L10n.insuranceAddonsSubheading)
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder
    private var movingToANewHomeView: some View {
        if !store.activeContracts.filter({ $0.typeOfContract.isHomeInsurance && !$0.isTerminated }).isEmpty,
            featureFlags.isMovingFlowEnabled
        {
            hSection {
                InfoCard(text: L10n.insurancesTabMovingFlowInfoTitle, type: .campaign)
                    .buttons([
                        .init(
                            buttonTitle: L10n.insurancesTabMovingFlowInfoButtonTitle,
                            buttonAction: {
                                contractsNavigationVm.isChangeAddressPresented = true
                            }
                        )
                    ])
            }
            .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
            .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
        }
    }
}

@MainActor
public class ContractTableViewModel: ObservableObject {
    @Published var viewState: ProcessingState = .loading
    @AppState private var store: ContractStore
    @Inject var service: FetchContractsClient
    @Published var addonBanners: [AddonBanner] = []
    private var cancellables = Set<AnyCancellable>()
    init() {
        store.$isFetchingContracts
            .combineLatest(store.$fetchContractsError)
            .receive(on: RunLoop.main)
            .sink { [weak self] isFetching, error in
                if isFetching {
                    self?.viewState = .loading
                } else if let error {
                    self?.viewState = .error(errorMessage: error)
                } else {
                    self?.viewState = .success
                }
            }
            .store(in: &cancellables)
    }

    func getAddonBanners() async {
        do {
            let addonBanners = try await service.getAddonBanners(source: .insurances)
            withAnimation {
                self.addonBanners = addonBanners
            }
        } catch {
            withAnimation {
                self.addonBanners = []
            }
        }
    }
}
