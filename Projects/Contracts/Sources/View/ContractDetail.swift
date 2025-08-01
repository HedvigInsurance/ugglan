import Combine
import Foundation
import PresentableStore
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import TerminateContracts
import hCore
import hCoreUI

enum ContractDetailsViews: String, CaseIterable, Identifiable {
    case overview
    case coverage
    case details

    var id: String { rawValue }
    var title: String {
        switch self {
        case .overview: return L10n.InsuranceDetailsView.tab1Title
        case .coverage: return L10n.InsuranceDetailsView.tab2Title
        case .details: return L10n.InsuranceDetailsView.tab3Title
        }
    }

    var index: Int {
        ContractDetailsViews.allCases.firstIndex(of: self) ?? 0
    }

    func move(_ otherPanel: ContractDetailsViews) -> AnyTransition {
        otherPanel.index < index ? .move(edge: .trailing) : .move(edge: .leading)
    }
}

public struct ContractDetail: View {
    @PresentableStore var store: ContractStore
    @StateObject private var vm: ContractDetailsViewModel
    var id: String

    @StateObject var scrollableSegmentedViewModel = ScrollableSegmentedViewModel(
        pageModels: ContractDetailsViews.allCases.compactMap { .init(id: $0.id, title: $0.title) }
    )
    @State private var selectedView = ContractDetailsViews.overview
    @EnvironmentObject var contractsNavigationVm: ContractsNavigationViewModel

    public init(
        id: String
    ) {
        self.id = id
        _vm = .init(wrappedValue: .init(id: id))
    }

    public var body: some View {
        if let contract = store.state.contractForId(id) {
            hForm {
                VStack(spacing: 0) {
                    hSection {
                        ContractRow(
                            image: contract.pillowType?.bgImage,
                            terminationMessage: contract.terminationMessage,
                            contractDisplayName: contract.currentAgreement?.productVariant.displayName ?? "",
                            contractExposureName: contract.exposureDisplayName,
                            activeFrom: contract.upcomingChangedAgreement?.activeFrom,
                            activeInFuture: contract.activeInFuture,
                            masterInceptionDate: contract.masterInceptionDate,
                            tierDisplayName: contract.currentAgreement?.productVariant.displayNameTier
                        )
                    }
                    ScrollableSegmentedView(
                        vm: scrollableSegmentedViewModel,
                        contentFor: { id in
                            Group {
                                switch ContractDetailsViews(rawValue: id) {
                                case .coverage:
                                    ContractCoverageView(id: contract.id)
                                case .details:
                                    ContractDocumentsView(id: contract.id)
                                case .overview:
                                    ContractInformationView(id: contract.id)
                                case .none:
                                    EmptyView()
                                }
                            }
                        }
                    )
                    .padding(.top, .padding16)
                    .padding(.bottom, .padding8)
                }
                .sectionContainerStyle(.transparent)
                .padding(.top, .padding8)
                Spacer(minLength: 0)
            }
            .presentableStoreLensAnimation(.default)
            .introspect(.viewController, on: .iOS(.v13...)) { [weak vm] vc in
                vm?.vc = vc
            }
        }
    }
}

@MainActor
class ContractDetailsViewModel: ObservableObject {
    private let id: String
    @PresentableStore var store: ContractStore
    weak var vc: UIViewController?
    var observeContractStateCancellable: AnyCancellable?
    init(id: String) {
        self.id = id
        observeContractState()
    }

    private func observeContractState() {
        let id = self.id
        observeContractStateCancellable = store.stateSignal
            .map { $0.contractForId(id)?.id }
            .eraseToAnyPublisher()
            .removeDuplicates()
            .sink { [weak self] value in
                if value == nil {
                    self?.vc?.navigationController?.popToRootViewController(animated: true)
                }
            }
    }
}
