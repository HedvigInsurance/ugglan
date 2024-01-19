import Flow
import Form
import Foundation
import Hero
import Presentation
import SwiftUI
import TerminateContracts
import UIKit
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
    @EnvironmentObject var context: TabControllerContext

    var id: String
    var title: String

    let contractOverview: ContractInformationView
    let contractCoverage: ContractCoverageView
    let contractDocuments: ContractDocumentsView

    @State private var selectedView = ContractDetailsViews.overview

    @ViewBuilder
    func viewFor(view: ContractDetailsViews) -> some View {
        switch view {
        case .overview:
            contractOverview
        case .coverage:
            contractCoverage
                .padding(.top, 8)
        case .details:
            contractDocuments
                .padding(.top, 8)
        }
    }

    public init(
        id: String,
        title: String
    ) {
        self.id = id
        self.title = title
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
        let contract = store.state.contractForId(id)
        hForm {
            hSection {
                ContractRow(
                    image: contract?.pillowType?.bgImage,
                    terminationMessage: contract?.terminationMessage,
                    contractDisplayName: contract?.currentAgreement?.productVariant.displayName ?? "",
                    contractExposureName: contract?.exposureDisplayName ?? ""
                )
                .fixedSize(horizontal: false, vertical: true)
                Picker("View", selection: $context.selected) {
                    ForEach(ContractDetailsViews.allCases) { view in
                        hText(view.title, style: .standardSmall).tag(view)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top, 16)
                .padding(.bottom, 8)
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, 8)
            VStack(spacing: 4) {
                ForEach(ContractDetailsViews.allCases) { panel in
                    if context.trigger == panel {
                        viewFor(view: panel)
                            .transition(.asymmetric(insertion: context.insertion, removal: context.removal))
                            .animation(.interpolatingSpring(stiffness: 300, damping: 70).speed(2))
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .presentableStoreLensAnimation(.default)
    }
}

extension ContractDetail {
    public func journey<ResultJourney: JourneyPresentation>(
        style: PresentationStyle = .default,
        @JourneyBuilder resultJourney: @escaping (_ result: ContractsResult) -> ResultJourney,
        options: PresentationOptions = [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never)]
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: self.environmentObject(TabControllerContext()),
            style: style,
            options: options
        ) { action in
            if case let .contractDetailNavigationAction(action: .document(url, title)) = action {
                Journey(
                    Document(url: url, title: title),
                    style: .detented(.large)
                )
                .withDismissButton
            } else if case let .contractDetailNavigationAction(action: .openInsuranceUpdate(contract)) = action {
                UpcomingChangesScreen.journey(contract: contract)
            } else if case .goToFreeTextChat = action {
                resultJourney(.openFreeTextChat)
            }
        }
        .configureTitle(title)
    }

    public var contractDetailErrorJourney: some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: GenericErrorView(
                description: L10n.contractDetailsError,
                buttons: .init(
                    actionButton: .init(
                        buttonTitle: L10n.generalCloseButton,
                        buttonAction: {
                            let store: ContractStore = globalPresentableStoreContainer.get()
                            store.send(.dismisscontractDetailNavigation)
                        }
                    ),
                    dismissButton: .init(
                        buttonAction: {
                            let store: ContractStore = globalPresentableStoreContainer.get()
                            store.send(.goToFreeTextChat)
                        })
                )
            )
        ) { action in
            if case .goToFreeTextChat = action {
                DismissJourney()
            } else if case .dismisscontractDetailNavigation = action {
                DismissJourney()
            }
        }
    }
}
