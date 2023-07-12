import Flow
import Form
import Foundation
import Hero
import Presentation
import SwiftUI
import UIKit
import hAnalytics
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

struct ContractDetail: View {
    @PresentableStore var store: ContractStore
    @EnvironmentObject var context: TabControllerContext

    var id: String

    let contractOverview: ContractInformationView
    let contractCoverage: ContractCoverageView
    let contractDetails: ContractDocumentsView

    @State private var selectedView = ContractDetailsViews.overview

    @ViewBuilder
    func viewFor(view: ContractDetailsViews) -> some View {
        switch view {
        case .overview:
            contractOverview
        case .coverage:
            contractCoverage
        case .details:
            contractDetails
        }
    }

    init(
        id: String
    ) {
        self.id = id

        contractOverview = ContractInformationView(id: id)
        contractCoverage = ContractCoverageView(
            id: id
        )
        contractDetails = ContractDocumentsView(id: id)

        let font = Fonts.fontFor(style: .footnote)
        UISegmentedControl.appearance()
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.foregroundColor: UIColor.brandNew(.secondaryText),
                    NSAttributedString.Key.font: font,
                ],
                for: .normal
            )

        UISegmentedControl.appearance()
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.foregroundColor: UIColor.brandNew(.primaryText(false)),
                    NSAttributedString.Key.font: font,
                ],
                for: .selected
            )
    }

    var body: some View {
        LoadingViewWithContent(ContractStore.self, [.startTermination]) {
            hForm {
                hSection {
                    ContractRow(
                        id: id,
                        allowDetailNavigation: false
                    )
                    .padding(.bottom, 20)
                    Picker("View", selection: $context.selected) {
                        ForEach(ContractDetailsViews.allCases) { view in
                            hText(view.title, style: .footnote).tag(view)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .withoutBottomPadding
                .sectionContainerStyle(.transparent)

                VStack(spacing: 4) {
                    ForEach(ContractDetailsViews.allCases) { panel in
                        if context.trigger == panel {
                            viewFor(view: panel)
                                .transition(.asymmetric(insertion: context.insertion, removal: context.removal))
                                .animation(.interpolatingSpring(stiffness: 300, damping: 70))
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .trackOnAppear(hAnalyticsEvent.screenView(screen: .insuranceDetail))
        .presentableStoreLensAnimation(.default)
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
                InsurableLimitDetail(limit: limit).journey
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
                .withDismissButton
            } else if case .contractEditInfo = action {
                HostingJourney(
                    rootView: CheckboxPickerScreen(
                        items: [
                            (EditInformation.coInsured.value, EditInformation.coInsured.title),
                            (EditInformation.changeAddress.value, EditInformation.changeAddress.title),
                        ],
                        preSelectedItems: { [] },
                        onSelected: { value in
                            if value.first == EditInformation.coInsured.value {
                                store.send(.goToFreeTextChat)
                            } else if value.first == EditInformation.coInsured.title {
                                store.send(.goToMovingFlow)
                            }
                        },
                        onCancel: {
                            //pop
                        },
                        singleSelect: true
                    ),
                    style: .detented(.scrollViewContentSize),
                    options: [.largeNavigationBar, .wantsGrabber, .blurredBackground]
                )
                .configureTitle(L10n.contractChangeInformationTitle)
                .withDismissButton
            }
        }
    }
}

enum EditInformation: String, CaseIterable, Identifiable {
    case coInsured
    case changeAddress

    var id: String { self.rawValue }

    var value: String {
        switch self {
        case .coInsured: return "coInsured"
        case .changeAddress: return "changeAddress"
        }
    }

    var title: String {
        switch self {
        case .coInsured: return "Edit co-insured"
        case .changeAddress: return "Change address"
        }
    }
}
