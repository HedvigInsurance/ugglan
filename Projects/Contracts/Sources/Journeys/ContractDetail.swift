import Combine
import Foundation
import Presentation
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

class TabControllerContext: ObservableObject {
    private typealias Views = ContractDetailsViews

    public init() {}

    @Published var selected = Views.overview {
        didSet {
            if previous != selected {
                insertion = selected.move(previous)
                removal = previous.move(selected)

                withAnimation {
                    trigger = selected
                    previous = selected
                }
            }
        }
    }

    @Published var trigger = Views.overview
    @Published var previous = Views.overview
    var insertion: AnyTransition = .move(edge: .leading)
    var removal: AnyTransition = .move(edge: .trailing)
}

public struct ContractDetail: View {
    @PresentableStore var store: ContractStore
    @StateObject var context = TabControllerContext()
    @StateObject private var vm: ContractDetailsViewModel
    var id: String

    let contractOverview: ContractInformationView
    let contractCoverage: ContractCoverageView
    let contractDocuments: ContractDocumentsView

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

        let font = Fonts.fontFor(style: .standardSmall)
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
                    Picker("View", selection: $context.selected) {
                        ForEach(ContractDetailsViews.allCases) { view in
                            hText(view.title, style: .standardSmall).tag(view)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, .padding16)
                    .padding(.bottom, .padding8)
                }
                .sectionContainerStyle(.transparent)
                .padding(.top, .padding8)
                VStack(spacing: 4) {
                    ForEach(ContractDetailsViews.allCases) { panel in
                        if context.trigger == panel {
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 70).speed(2)) {
                                viewFor(view: panel)
                                    .transition(.asymmetric(insertion: context.insertion, removal: context.removal))
                            }
                        }
                    }
                }
                .padding(.top, .padding16)
                .padding(.bottom, .padding8)
            }
            .presentableStoreLensAnimation(.default)
            .introspectViewController { [weak vm] vc in
                vm?.vc = vc
            }
        }
    }
}

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
        observeContractStateCancellable = store.stateSignal.plain()
            .publisher
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
