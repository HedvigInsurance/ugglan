import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ContractTable {
    @Inject var client: ApolloClient
    let presentingViewController: UIViewController
    let filter: ContractFilter
    @PresentableStore var store: ContractStore
}

extension ContractTable: Viewable {
    func materialize(events _: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()

        let sectionStyle = SectionStyle(
            insets: .zero,
            rowInsets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15),
            itemSpacing: 0,
            minRowHeight: 10,
            background: .init(all: UIColor.clear.asImage()),
            selectedBackground: .init(all: UIColor.clear.asImage()),
            shadow: .none,
            header: .none,
            footer: .none
        )

        let dynamicSectionStyle = DynamicSectionStyle { _ in sectionStyle }

        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)

        let tableKit = TableKit<EmptySection, ContractRow>(style: style)
        bag += tableKit.view.addTableFooterView(ContractTableFooter(filter: filter))

        tableKit.view.backgroundColor = .brand(.primaryBackground())
        tableKit.view.alwaysBounceVertical = true

        let loadingIndicatorBag = DisposeBag()

        let loadingIndicator = LoadingIndicator(showAfter: 0.5, color: .brand(.primaryTintColor))
        loadingIndicatorBag += tableKit.view.add(loadingIndicator) { view in
            view.snp.makeConstraints { make in make.top.equalTo(0) }

            loadingIndicatorBag += tableKit.view.signal(for: \.contentSize)
                .onValue { size in
                    view.snp.updateConstraints { make in
                        make.top.equalTo(size.height - (view.frame.height / 2))
                    }
                }
        }

        func getContractsToShow(for state: ContractState) -> [Contract] {
            switch self.filter {
            case .active:
                return state
                    .contractBundles
                    .flatMap { $0.contracts }
            case .terminated:
                return state.contracts.filter { contract in
                    contract.currentAgreement.status == .terminated
                }
            case .none: return []
            }
        }

        bag += store
            .stateSignal
            .atOnce()
            .onValue { state in
                let contractsToShow = getContractsToShow(for: state)

                let table = Table(
                    rows: contractsToShow.map { contract -> ContractRow in
                        ContractRow(
                            contract: contract
                        )
                    }
                )

                loadingIndicatorBag.dispose()

                tableKit.set(table)
            }

        bag += tableKit.view.didMoveToWindowSignal.onValue { _ in
            store.send(.fetchContractBundles)
            store.send(.fetchContracts)
        }

        return (tableKit.view, bag)
    }
}
