import Combine
import Foundation
import StoreContainer
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI
import hGraphQL

enum ContractDetailsViews: String, CaseIterable, Identifiable {
    case overview
    case coverage
    case details

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .overview: return L10n.InsuranceDetailsView.tab1Title
        case .coverage: return L10n.InsuranceDetailsView.tab2Title
        case .details: return L10n.InsuranceDetailsView.tab3Title
        }
    }

    var index: Int {
        return ContractDetailsViews.allCases.firstIndex(of: self) ?? 0
    }

    func move(_ otherPanel: ContractDetailsViews) -> AnyTransition {
        return otherPanel.index < self.index ? .move(edge: .trailing) : .move(edge: .leading)
    }
}

public struct ContractDetail: View {
    @hPresentableStore var store: ContractStore
    @StateObject private var vm: ContractDetailsViewModel
    var id: String

    let contractOverview: ContractInformationView
    let contractCoverage: ContractCoverageView
    let contractDocuments: ContractDocumentsView
    @StateObject var crollableSegmentedViewModel = ScrollableSegmentedViewModel(
        pageModels: ContractDetailsViews.allCases.compactMap({ .init(id: $0.id, title: $0.title) })
    )
    @State private var selectedView = ContractDetailsViews.overview
    @EnvironmentObject var contractsNavigationVm: ContractsNavigationViewModel

    @ViewBuilder
    func viewFor(view: ContractDetailsViews) -> some View {
        switch view {
        case .overview:
            contractOverview
        case .coverage:
            contractCoverage
                .padding(.top, .padding8)
        case .details:
            contractDocuments
                .padding(.top, .padding8)
        }
    }

    public init(
        id: String
    ) {
        self.id = id
        self._vm = .init(wrappedValue: .init(id: id))
        contractOverview = ContractInformationView(id: id)
        contractCoverage = ContractCoverageView(id: id)
        contractDocuments = ContractDocumentsView(id: id)

        let font = Fonts.fontFor(style: .label)
        UISegmentedControl.appearance()
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.foregroundColor: UIColor.brand(.secondaryText),
                    NSAttributedString.Key.font: font,
                ],
                for: .normal
            )

        UISegmentedControl.appearance()
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText(false)),
                    NSAttributedString.Key.font: font,
                ],
                for: .selected
            )
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
                            masterInceptionDate: contract.masterInceptionDate
                        )
                    }
                    ScrollableSegmentedView(
                        vm: crollableSegmentedViewModel,
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
            }
            .hPresentableStoreLensAnimation(.default)
            .introspectViewController { [weak vm] vc in
                vm?.vc = vc
            }
        }
    }
}

class ContractDetailsViewModel: ObservableObject {
    private let id: String
    @hPresentableStore var store: ContractStore
    weak var vc: UIViewController?
    var observeContractStateCancellable: AnyCancellable?
    init(id: String) {
        self.id = id
        observeContractState()
    }

    private func observeContractState() {
        let id = self.id
        observeContractStateCancellable = store.stateSignal
            .map({ $0.contractForId(id)?.id })
            .eraseToAnyPublisher()
            .removeDuplicates()
            .sink { [weak self] value in
                if value == nil {
                    self?.vc?.navigationController?.popToRootViewController(animated: true)
                }
            }
    }
}
