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
}

struct ContractDetail: View {
    var contractRow: ContractRow
    
    let contractInformation: ContractInformation
    let contractCoverage: ContractCoverage
    let contractDocuments: ContractDocuments
    
    @State private var selectedView = ContractDetailsViews.information
    
    @State private var showingImagePicker = false
    
    init(
        contractRow: ContractRow
    ) {
        self.contractRow = contractRow
        self.contractRow.allowDetailNavigation = false
        
        contractInformation = ContractInformation(contract: contractRow.contract)
        contractCoverage = ContractCoverage(
            perils: contractRow.contract.contractPerils,
            insurableLimits: contractRow.contract.insurableLimits
        )
        contractDocuments = ContractDocuments(contract: contractRow.contract)
    }
    
    var body: some View {
        hForm {
            hSection {
                contractRow.padding(.bottom, 20)
                Picker("View", selection: $selectedView) {
                    ForEach(ContractDetailsViews.allCases) { view in
                        Text(view.title).tag(view)
                    }
                }.pickerStyle(.segmented)
                Button("Select Image") {
                    self.showingImagePicker = true
                }
            }.sectionContainerStyle(.transparent)
            ContractInformationz(contract: contractRow.contract)
            .sheet(isPresented: $showingImagePicker) { ContractInformationView(contract: contractRow.contract) }
        }
    }
}

extension ContractDetail {
    public static func journey(contractRow: ContractRow) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: ContractDetail(contractRow: contractRow).navigationBarTitle("", displayMode: .inline)
        ) { _ in
            ContinueJourney()
        }
    }
}


struct ContractDetailz {
    var contractRow: ContractRow

    init(
        contractRow: ContractRow
    ) {
        self.contractRow = contractRow
        self.contractRow.allowDetailNavigation = false
    }
}

extension ContractDetailz: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let scrollView = FormScrollView()
        let form = FormView()

        form.appendSpacing(.inbetween)

        let contractRowHost = HostingView(
            rootView: VStack {
                contractRow
            }
            .padding(16)
        )
        form.append(contractRowHost)

        let contractInformation = ContractInformation(contract: contractRow.contract)

        let contractCoverage = ContractCoverage(
            perils: contractRow.contract.contractPerils,
            insurableLimits: contractRow.contract.insurableLimits
        )

        let contractDocuments = ContractDocuments(contract: contractRow.contract)

        var contractDetailCollection = ContractDetailCollection(
            rows: [
                ContractDetailPresentableRow(presentable: AnyPresentable(contractInformation)),
                ContractDetailPresentableRow(presentable: AnyPresentable(contractCoverage)),
                ContractDetailPresentableRow(presentable: AnyPresentable(contractDocuments)),
            ],
            currentIndex: IndexPath(row: 0, section: 0)
        )

        bag += form.append(ContractDetailSegmentedControl(form: form, scrollView: scrollView))
            .onValue { index in contractDetailCollection.currentIndex = index }

        bag += form.append(contractDetailCollection) { contractDetailCollectionView in
            contractDetailCollectionView.hero.modifiers = [
                .translate(x: 0, y: 40, z: 0), .opacity(0), .spring(stiffness: 250, damping: 30),
            ]
        }

        bag += viewController.install(form, options: [], scrollView: scrollView)

        return (viewController, bag)
    }
}
