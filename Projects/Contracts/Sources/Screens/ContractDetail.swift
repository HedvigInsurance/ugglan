import Flow
import Form
import Foundation
import Hero
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

enum ContractDetailsViews: String, CaseIterable, Identifiable {
    case information
    case coverage
    case documents

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .information: return L10n.InsuranceDetailsView.tab1Title
        case .coverage: return L10n.InsuranceDetailsView.tab2Title
        case .documents: return L10n.InsuranceDetailsView.tab3Title
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

    @Published var selected = Views.information {
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

    @Published var trigger = Views.information
    @Published var previous = Views.information
    var insertion: AnyTransition = .move(edge: .leading)
    var removal: AnyTransition = .move(edge: .trailing)
}

struct ContractDetail: View {
    @PresentableStore var store: ContractStore
    @EnvironmentObject var context: TabControllerContext

    var contractRow: ContractRow

    let contractInformation: ContractInformationView
    let contractCoverage: ContractCoverageView
    let contractDocuments: ContractDocumentsView

    @State private var selectedView = ContractDetailsViews.information

    @ViewBuilder
    func viewFor(view: ContractDetailsViews) -> some View {
        switch view {
        case .information:
            contractInformation
        case .coverage:
            contractCoverage
        case .documents:
            contractDocuments
        }
    }

    init(
        contractRow: ContractRow
    ) {
        self.contractRow = contractRow
        self.contractRow.allowDetailNavigation = false

        contractInformation = ContractInformationView(contract: contractRow.contract)
        contractCoverage = ContractCoverageView(
            perils: contractRow.contract.contractPerils,
            insurableLimits: contractRow.contract.insurableLimits
        )
        contractDocuments = ContractDocumentsView(contract: contractRow.contract)

        let font = Fonts.fontFor(style: .footnote)
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
                    NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
                    NSAttributedString.Key.font: font,
                ],
                for: .selected
            )
    }

    var body: some View {
        VStack {
            hForm {
                hSection {
                    contractRow.padding(.bottom, 20)
                    Picker("View", selection: $context.selected) {
                        ForEach(ContractDetailsViews.allCases) { view in
                            hText(view.title).tag(view)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .sectionContainerStyle(.transparent)

                ForEach(ContractDetailsViews.allCases) { panel in
                    if context.trigger == panel {
                        viewFor(view: panel)
                            .transition(.asymmetric(insertion: context.insertion, removal: context.removal))
                    }
                }
            }
        }
    }
}

extension ContractDetail {
    public func journey(
        style: PresentationStyle = .default,
        options: PresentationOptions = [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: self.environmentObject(TabControllerContext()),
            style: style,
            options: options
        ) { action in
            if case let .contractDetailNavigationAction(action: .peril(peril)) = action {
                Journey(
                    PerilDetail(peril: peril),
                    style: .detented(.preferredContentSize, .large)
                )
                .withDismissButton
            } else if case let .contractDetailNavigationAction(action: .insurableLimit(limit)) = action {
                InsurableLimitDetail(limit: limit).journey.withDismissButton
            } else if case let .contractDetailNavigationAction(action: .document(url, title)) = action {
                Journey(
                    Document(url: url, title: title),
                    style: .detented(.large)
                )
                .withDismissButton
            } else if case let .contractDetailNavigationAction(action: .upcomingAgreement(details)) = action {
                Journey(
                    UpcomingAddressChangeDetails(details: details),
                    style: .detented(.scrollViewContentSize, .large)
                )
            }
        }
    }
}
