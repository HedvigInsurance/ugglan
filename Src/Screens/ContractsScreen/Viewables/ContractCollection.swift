//
//  ContractCollection.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-16.
//

import Foundation
import Flow
import Form
import Apollo

struct ContractCollection {
    @Inject var client: ApolloClient
}

extension ContractsQuery.Data.Contract.CurrentAgreement {
    var state: ContractRow.State {
        if let norwegianHomeContents = self.asNorwegianHomeContentAgreement {
            switch norwegianHomeContents.status {
            case .active:
                return .active
            case .activeInFuture:
                return .coming
            case .terminated:
                return .cancelled(from: norwegianHomeContents.activeTo?.localDateToDate ?? Date())
            case .pending:
                return .coming
            case .__unknown(_):
                return .coming
            }
        } else if let norwegianTravel = self.asNorwegianTravelAgreement {
            switch norwegianTravel.status {
            case .active:
                return .active
            case .activeInFuture:
                return .coming
            case .terminated:
                return .cancelled(from: norwegianTravel.activeTo?.localDateToDate ?? Date())
            case .pending:
                return .coming
            case .__unknown(_):
                return .coming
            }
        } else if let swedishApartment = self.asSwedishApartmentAgreement {
            switch swedishApartment.status {
            case .active:
                return .active
            case .activeInFuture:
                return .coming
            case .terminated:
                return .cancelled(from: swedishApartment.activeTo?.localDateToDate ?? Date())
            case .pending:
                return .coming
            case .__unknown(_):
                return .coming
            }
        } else if let swedishHouse = self.asSwedishHouseAgreement {
            switch swedishHouse.status {
            case .active:
                return .active
            case .activeInFuture:
                return .coming
            case .terminated:
                return .cancelled(from: swedishHouse.activeTo?.localDateToDate ?? Date())
            case .pending:
                return .coming
            case .__unknown(_):
                return .coming
            }
        }
        
        return .coming
    }
    
    var type: ContractRow.ContractType {
        if let _ = self.asNorwegianHomeContentAgreement {
            return .norwegianHome
        } else if let _ = self.asNorwegianTravelAgreement {
            return .norwegianTravel
        } else if let _ = self.asSwedishApartmentAgreement {
            return .swedishApartment
        } else if let _ = self.asSwedishHouseAgreement {
            return .swedishHouse
        }
        
        fatalError("Unrecognised agreement provided")
    }
    
    var certificateUrl: URL? {
        if let norwegianHomeContents = self.asNorwegianHomeContentAgreement {
            return URL(string: norwegianHomeContents.certificateUrl)
        } else if let norwegianTravel = self.asNorwegianTravelAgreement {
            return URL(string: norwegianTravel.certificateUrl)
        } else if let swedishApartment = self.asSwedishApartmentAgreement {
            return URL(string: swedishApartment.certificateUrl)
        } else if let swedishHouse = self.asSwedishHouseAgreement {
           return URL(string: swedishHouse.certificateUrl)
        }
        
        return nil
    }
    
    var summary: String? {
        if let norwegianHomeContents = self.asNorwegianHomeContentAgreement {
            return norwegianHomeContents.address.street
        } else if let norwegianTravel = self.asNorwegianTravelAgreement {
            return String(norwegianTravel.numberCoInsured)
        } else if let swedishApartment = self.asSwedishApartmentAgreement {
            return swedishApartment.address.street
        } else if let swedishHouse = self.asSwedishHouseAgreement {
           return swedishHouse.address.street
        }
        
        return nil
    }
}

extension ContractCollection: Viewable {
    func materialize(events: ViewableEvents) -> (UITableView, Disposable) {
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
            query: ContractsQuery()
        ).valueSignal.compactMap { $0.data?.contracts }.onValue({ contracts in
            
            let table = Table(rows: contracts.map({ contract -> ContractRow in
                ContractRow(
                    contract: contract,
                    displayName: contract.displayName,
                    state: contract.currentAgreement.state,
                    type: contract.currentAgreement.type
                )
            }))
            
            tableKit.set(table)
        })

        return (tableKit.view, bag)
    }
}
