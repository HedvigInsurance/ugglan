//
//  ContractCollection.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-16.
//

import Apollo
import Flow
import Form
import Foundation

struct ContractCollection {
    @Inject var client: ApolloClient
}

extension ContractsQuery.Data.Contract.CurrentAgreement {
    var state: ContractRow.State {
        if let norwegianHomeContents = asNorwegianHomeContentAgreement {
            switch norwegianHomeContents.status {
            case .active:
                return .active
            case .activeInFuture:
                return .coming
            case .terminated:
                return .cancelled(from: norwegianHomeContents.activeTo?.localDateToDate ?? Date())
            case .pending:
                return .coming
            case .__unknown:
                return .coming
            }
        } else if let norwegianTravel = asNorwegianTravelAgreement {
            switch norwegianTravel.status {
            case .active:
                return .active
            case .activeInFuture:
                return .coming
            case .terminated:
                return .cancelled(from: norwegianTravel.activeTo?.localDateToDate ?? Date())
            case .pending:
                return .coming
            case .__unknown:
                return .coming
            }
        } else if let swedishApartment = asSwedishApartmentAgreement {
            switch swedishApartment.status {
            case .active:
                return .active
            case .activeInFuture:
                return .coming
            case .terminated:
                return .cancelled(from: swedishApartment.activeTo?.localDateToDate ?? Date())
            case .pending:
                return .coming
            case .__unknown:
                return .coming
            }
        } else if let swedishHouse = asSwedishHouseAgreement {
            switch swedishHouse.status {
            case .active:
                return .active
            case .activeInFuture:
                return .coming
            case .terminated:
                return .cancelled(from: swedishHouse.activeTo?.localDateToDate ?? Date())
            case .pending:
                return .coming
            case .__unknown:
                return .coming
            }
        }

        return .coming
    }

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

    var certificateUrl: URL? {
        if let norwegianHomeContents = asNorwegianHomeContentAgreement {
            return URL(string: norwegianHomeContents.certificateUrl)
        } else if let norwegianTravel = asNorwegianTravelAgreement {
            return URL(string: norwegianTravel.certificateUrl)
        } else if let swedishApartment = asSwedishApartmentAgreement {
            return URL(string: swedishApartment.certificateUrl)
        } else if let swedishHouse = asSwedishHouseAgreement {
            return URL(string: swedishHouse.certificateUrl)
        }

        return nil
    }

    var summary: String? {
        if let norwegianHomeContents = asNorwegianHomeContentAgreement {
            return norwegianHomeContents.address.street
        } else if let norwegianTravel = asNorwegianTravelAgreement {
            return String(norwegianTravel.numberCoInsured)
        } else if let swedishApartment = asSwedishApartmentAgreement {
            return swedishApartment.address.street
        } else if let swedishHouse = asSwedishHouseAgreement {
            return swedishHouse.address.street
        }

        return nil
    }
}

extension ContractCollection: Viewable {
    func materialize(events _: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        let sectionStyle = SectionStyle(
            rowInsets: UIEdgeInsets(
                top: 10,
                left: 20,
                bottom: 10,
                right: 20
            ),
            itemSpacing: 0,
            minRowHeight: 10,
            background: .invisible,
            selectedBackground: .invisible,
            header: .none,
            footer: .none
        )

        let dynamicSectionStyle = DynamicSectionStyle { _ in
            sectionStyle
        }

        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .noInsets)

        let tableKit = TableKit<EmptySection, ContractRow>(style: style)

        tableKit.view.backgroundColor = .primaryBackground
        tableKit.view.alwaysBounceVertical = true

        bag += client.fetch(
            query: ContractsQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale())
        ).valueSignal.compactMap { $0.data?.contracts }.onValue { contracts in

            let table = Table(rows: contracts.map { contract -> ContractRow in
                ContractRow(
                    contract: contract,
                    displayName: contract.displayName,
                    state: contract.currentAgreement.state,
                    type: contract.currentAgreement.type
                )
            })

            tableKit.set(table)
        }

        return (tableKit.view, bag)
    }
}
