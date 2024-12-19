import Addons
import Apollo
import Combine
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ContractTable: View {
    @PresentableStore var store: ContractStore
    let showTerminated: Bool
    @State var onlyTerminatedInsurances = false
    @StateObject var vm = ContractTableViewModel()

    @EnvironmentObject var contractsNavigationVm: ContractsNavigationViewModel
    @EnvironmentObject var router: Router
    func getContractsToShow(for state: ContractState) -> [Contract] {
        if showTerminated {
            return state.terminatedContracts.compactMap { $0 }
        } else {
            let activeContractsToShow = state.activeContracts.compactMap { $0 }
            let pendingContractsToShow = state.pendingContracts.compactMap { $0 }
            if !(activeContractsToShow + pendingContractsToShow).isEmpty {
                DispatchQueue.main.async {
                    onlyTerminatedInsurances = false
                }
                return activeContractsToShow + pendingContractsToShow
            } else {
                DispatchQueue.main.async {
                    onlyTerminatedInsurances = true
                }
                return state.terminatedContracts.compactMap { $0 }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            successView
                .loadingWithButtonLoading($vm.viewState)
                .hErrorViewButtonConfig(
                    .init(
                        actionButton: .init(buttonAction: {
                            store.send(.fetchContracts)
                        }),
                        dismissButton: nil
                    )
                )
            if !showTerminated {
                VStack(spacing: 24) {
                    hSection {
                        if Dependencies.featureFlags().isAddonsEnabled, let banner = vm.addonBannerModel {
                            let addonContracts = banner.contractIds.compactMap({
                                store.state.contractForId($0)
                            })

                            let addonContractConfig: [AddonConfig] = addonContracts.map({
                                .init(
                                    contractId: $0.id,
                                    exposureName: $0.exposureDisplayName,
                                    displayName: $0.currentAgreement?.productVariant.displayName ?? ""
                                )
                            })

                            AddonCardView(
                                openAddon: {
                                    contractsNavigationVm.isAddonPresented = .init(
                                        contractConfigs: addonContractConfig,
                                        addonId: nil
                                    )
                                },
                                addon: banner
                            )
                        }
                    }
                    .sectionContainerStyle(.transparent)

                    movingToANewHomeView
                    CrossSellingStack(withHeader: true)

                    PresentableStoreLens(
                        ContractStore.self,
                        getter: { state in
                            state.terminatedContracts
                        }
                    ) { terminatedContracts in
                        if !(terminatedContracts.isEmpty || onlyTerminatedInsurances) {
                            hSection {
                                hButton.LargeButton(type: .secondary) {
                                    router.push(ContractsRouterType.terminatedContracts)
                                } content: {
                                    hRow {
                                        HStack {
                                            hText(
                                                L10n.InsurancesTab.cancelledInsurancesLabel(
                                                    "\(terminatedContracts.count)"
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
                        }
                    }
                    .presentableStoreLensAnimation(.spring())
                    .sectionContainerStyle(.transparent)
                }
                .padding(.vertical, .padding24)
            }
        }
        .onAppear {
            Task {
                await vm.getAddonBanner()
            }
        }
    }

    private var successView: some View {
        hSection {
            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    getContractsToShow(for: state)

                }
            ) { contracts in
                VStack(spacing: .padding8) {
                    ForEach(contracts, id: \.id) { contract in
                        ContractRow(
                            image: contract.pillowType?.bgImage,
                            terminationMessage: contract.terminationMessage,
                            contractDisplayName: contract.currentAgreement?.productVariant.displayName ?? "",
                            contractExposureName: contract.exposureDisplayName,
                            activeFrom: contract.upcomingChangedAgreement?.activeFrom,
                            activeInFuture: contract.activeInFuture,
                            masterInceptionDate: contract.masterInceptionDate,
                            tierDisplayName: contract.currentAgreement?.productVariant.displayNameTier,
                            onClick: {
                                router.push(contract)
                            }
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.slide)
                    }
                }
            }
        }
        .presentableStoreLensAnimation(.spring())
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private var movingToANewHomeView: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.activeContracts
            }
        ) { activeContracts in
            if !activeContracts.filter({ $0.typeOfContract.isHomeInsurance && !$0.isTerminated }).isEmpty
                && Dependencies.featureFlags().isMovingFlowEnabled
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
                .withHeader {
                    hText(L10n.insurancesTabMovingFlowSectionTitle)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .padding(.leading, 2)
                }
            }
        }
    }
}

@MainActor
public class ContractTableViewModel: ObservableObject {
    @Published var viewState: ProcessingState = .loading
    @PresentableStore var store: ContractStore
    @Published var loadingCancellable: AnyCancellable?
    @Inject var service: FetchContractsClient
    @Published var addonBannerModel: AddonBannerModel?
    private var addonAddedObserver: NSObjectProtocol?

    init() {
        loadingCancellable = store.loadingSignal
            .receive(on: RunLoop.main)
            .sink { _ in
            } receiveValue: { [weak self] action in
                let getAction = action.first(where: { $0.key == .fetchContracts })
                switch getAction?.value {
                case let .error(errorMessage):
                    self?.viewState = .error(errorMessage: errorMessage)
                case .loading:
                    self?.viewState = .loading
                default:
                    self?.viewState = .success
                }
            }

        addonAddedObserver = NotificationCenter.default.addObserver(forName: .addonAdded, object: nil, queue: nil) {
            [weak self] notification in
            Task {
                await self?.getAddonBanner()
            }
        }
    }

    deinit {
        Task { @MainActor [weak self] in
            if let addonAddedObserver = self?.addonAddedObserver {
                NotificationCenter.default.removeObserver(addonAddedObserver)
            }
        }
    }

    func getAddonBanner() async {
        do {
            self.addonBannerModel = try await service.getAddonBannerModel(source: .appOnlyUpsell)
        } catch {

        }
    }
}
