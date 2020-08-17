//
//  ContractTable.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-16.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct ContractTable {
    @Inject var client: ApolloClient
    let presentingViewController: UIViewController
}

extension GraphQL.ContractsQuery.Data.Contract.CurrentAgreement {
    var type: ContractRow.ContractType {
        if let _ = asNorwegianHomeContentAgreement {
            return .norwegianHome
        } else if let _ = asNorwegianTravelAgreement {
            return .norwegianTravel
        } else if let _ = asSwedishApartmentAgreement {
            return .swedishApartment
        } else if let _ = asSwedishHouseAgreement {
            return .swedishHouse
        }

        fatalError("Unrecognised agreement provided")
    }

    var summary: String? {
        if let norwegianHomeContents = asNorwegianHomeContentAgreement {
            return norwegianHomeContents.address.street
        } else if let norwegianTravel = asNorwegianTravelAgreement {
            if norwegianTravel.numberCoInsured > 0 {
                return L10n.dashboardMyInfoCoinsured(norwegianTravel.numberCoInsured)
            }

            return L10n.dashboardMyInfoNoCoinsured
        } else if let swedishApartment = asSwedishApartmentAgreement {
            return swedishApartment.address.street
        } else if let swedishHouse = asSwedishHouseAgreement {
            return swedishHouse.address.street
        }

        return nil
    }
}

extension ContractTable: Viewable {
    func materialize(events _: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()

        let sectionStyle = SectionStyle(
            rowInsets: UIEdgeInsets(
                top: 10,
                left: 20,
                bottom: 10,
                right: 20
            ),
            itemSpacing: 0,
            minRowHeight: 10,
            background: .init(all: UIColor.clear.asImage()),
            selectedBackground: .init(all: UIColor.clear.asImage()),
            header: .none,
            footer: .none
        )

        let dynamicSectionStyle = DynamicSectionStyle { _ in
            sectionStyle
        }
        
        let noInsets = DynamicFormStyle { _ -> FormStyle in
            FormStyle(insets: .zero)
        }

        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: noInsets)

        let tableKit = TableKit<EmptySection, ContractRow>(style: style)
        bag += tableKit.view.addTableFooterView(UpsellingFooter())

        tableKit.view.backgroundColor = .brand(.primaryBackground())
        tableKit.view.alwaysBounceVertical = true
        
        bag += tableKit.view.didMoveToWindowSignal.onValue { _ in
            ContextGradient.currentOption = .insurance
        }

        let loadingIndicatorBag = DisposeBag()

        let loadingIndicator = LoadingIndicator(showAfter: 0.5, color: .brand(.primaryTintColor))
        loadingIndicatorBag += tableKit.view.add(loadingIndicator) { view in
            view.snp.makeConstraints { make in
                make.top.equalTo(0)
            }

            loadingIndicatorBag += tableKit.view.signal(for: \.contentSize).onValue { size in
                view.snp.updateConstraints { make in
                    make.top.equalTo(size.height - (view.frame.height / 2))
                }
            }
        }

        func loadContracts() {
            bag += client.fetch(
                query: GraphQL.ContractsQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()),
                cachePolicy: .fetchIgnoringCacheData
            ).valueSignal.compactMap { $0.data?.contracts }.onValue { contracts in
                let table = Table(rows: contracts.map { contract -> ContractRow in
                    ContractRow(
                        contract: contract,
                        displayName: contract.displayName,
                        type: contract.currentAgreement.type
                    )
                })

                loadingIndicatorBag.dispose()

                tableKit.set(table)
            }
        }

        loadContracts()

        // todo
        //bag += NotificationCenter.default.signal(forName: .localeSwitched).onValue { _ in
        //    loadContracts()
        //}

        return (tableKit.view, bag)
    }
}
