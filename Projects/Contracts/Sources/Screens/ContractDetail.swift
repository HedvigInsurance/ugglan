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
    
    @Published var selected = Views.information { didSet {
        if previous != selected {
            insertion = selected.move(previous)
            removal = previous.move(selected)

            withAnimation {
                trigger = selected
                previous = selected
            }
        }
    }}
    
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
    
    func viewFor(view: ContractDetailsViews) -> some View {
        switch view {
        case .information:
            return AnyView(contractInformation)
        case .coverage:
            return AnyView(contractCoverage)
        case .documents:
            return AnyView(contractDocuments)
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
    }
    
    var body: some View {
        VStack {
            hForm {
                hSection {
                    contractRow.padding(.bottom, 20)
                    Picker("View", selection: $context.selected) {
                        ForEach(ContractDetailsViews.allCases) { view in
                            Text(view.title).tag(view)
                        }
                    }.pickerStyle(.segmented)
                }.sectionContainerStyle(.transparent)
                
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
        options: PresentationOptions = [.defaults]
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
                ).withDismissButton
            } else if case let .contractDetailNavigationAction(action: .upcomingAgreement(details)) = action {
                Journey(
                    UpcomingAddressChangeDetails(details: details),
                    style: .detented(.scrollViewContentSize, .large)
                )
            }
        }
    }
}
//
//
//struct ContractDetailz {
//    var contractRow: ContractRow
//
//    init(
//        contractRow: ContractRow
//    ) {
//        self.contractRow = contractRow
//        self.contractRow.allowDetailNavigation = false
//    }
//}
//
//extension ContractDetailz: Presentable {
//    func materialize() -> (UIViewController, Disposable) {
//        let viewController = UIViewController()
//        let bag = DisposeBag()
//
//        let scrollView = FormScrollView()
//        let form = FormView()
//
//        form.appendSpacing(.inbetween)
//
//        let contractRowHost = HostingView(
//            rootView: VStack {
//                contractRow
//            }
//            .padding(16)
//        )
//        form.append(contractRowHost)
//
//        let contractInformation = ContractInformation(contract: contractRow.contract)
//
//        let contractCoverage = ContractCoverage(
//            perils: contractRow.contract.contractPerils,
//            insurableLimits: contractRow.contract.insurableLimits
//        )
//
//        let contractDocuments = ContractDocuments(contract: contractRow.contract)
//
//        var contractDetailCollection = ContractDetailCollection(
//            rows: [
//                ContractDetailPresentableRow(presentable: AnyPresentable(contractInformation)),
//                ContractDetailPresentableRow(presentable: AnyPresentable(contractCoverage)),
//                ContractDetailPresentableRow(presentable: AnyPresentable(contractDocuments)),
//            ],
//            currentIndex: IndexPath(row: 0, section: 0)
//        )
//
//        bag += form.append(ContractDetailSegmentedControl(form: form, scrollView: scrollView))
//            .onValue { index in contractDetailCollection.currentIndex = index }
//
//        bag += form.append(contractDetailCollection) { contractDetailCollectionView in
//            contractDetailCollectionView.hero.modifiers = [
//                .translate(x: 0, y: 40, z: 0), .opacity(0), .spring(stiffness: 250, damping: 30),
//            ]
//        }
//
//        bag += viewController.install(form, options: [], scrollView: scrollView)
//
//        return (viewController, bag)
//    }
//}
