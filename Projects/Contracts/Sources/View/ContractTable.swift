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
            successView.loading($vm.viewState, showLoading: false)
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
    @Published var actionCancellable: AnyCancellable?
    @Published var loadingCancellable: AnyCancellable?

    init() {
        actionCancellable = store.actionSignal
            .receive(on: RunLoop.main)
            .sink { _ in
            } receiveValue: { [weak self] action in
                if action == .fetchContracts {
                    self?.viewState = .success
                }
            }

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
                default: break
                }
            }
    }
}
