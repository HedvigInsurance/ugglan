//
//  InsuranceSummarySection.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-03.
//

import Foundation
import Flow
import UIKit
import Apollo
import Form

struct InsuranceSummarySection {
    let client: ApolloClient
    let headerView: UIView?
    let footerView: UIView?
    
    init(
        headerView: UIView? = nil,
        footerView: UIView? = nil,
        client: ApolloClient = ApolloContainer.shared.client
    ) {
        self.headerView = headerView
        self.footerView = footerView
        self.client = client
    }
}

extension InsuranceSummarySection: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let sectionView = SectionView(
            headerView: headerView,
            footerView: footerView
        )
        sectionView.dynamicStyle = .sectionPlain
        
        bag += client.watch(query: MyHomeQuery()).onValueDisposePrevious { result in
            let innerBag = DisposeBag()
        if let insurance = result.data?.insurance {

            let adressRow = KeyValueRow()
            adressRow.keySignal.value = String(key: .MY_HOME_ADDRESS_ROW_KEY)
            adressRow.valueSignal.value = insurance.address ?? ""
            adressRow.valueStyleSignal.value = .rowTitleDisabled
            innerBag += sectionView.append(adressRow)

            let postalCodeRow = KeyValueRow()
            postalCodeRow.keySignal.value = String(key: .MY_HOME_ROW_POSTAL_CODE_KEY)
            postalCodeRow.valueSignal.value = insurance.postalNumber ?? ""
            postalCodeRow.valueStyleSignal.value = .rowTitleDisabled
            innerBag += sectionView.append(postalCodeRow)

            let livingSpaceRow = KeyValueRow()
            livingSpaceRow.keySignal.value = String(key: .MY_HOME_ROW_SIZE_KEY)

            if let livingSpace = insurance.livingSpace {
                livingSpaceRow.valueSignal.value = String(key: .MY_HOME_ROW_SIZE_VALUE(
                    livingSpace: String(livingSpace)
                ))
                livingSpaceRow.valueStyleSignal.value = .rowTitleDisabled
                innerBag += sectionView.append(livingSpaceRow)
            }

            let apartmentTypeRow = KeyValueRow()
            apartmentTypeRow.keySignal.value = String(key: .MY_HOME_ROW_TYPE_KEY)
            apartmentTypeRow.valueStyleSignal.value = .rowTitleDisabled

            if let insuranceType = insurance.type {
                switch insuranceType {
                case .brf:
                    apartmentTypeRow.valueSignal.value = String(key: .MY_HOME_ROW_TYPE_CONDOMINIUM_VALUE)
                case .studentBrf:
                    apartmentTypeRow.valueSignal.value = String(key: .MY_HOME_ROW_TYPE_CONDOMINIUM_VALUE)
                case .rent:
                    apartmentTypeRow.valueSignal.value = String(key: .MY_HOME_ROW_TYPE_RENTAL_VALUE)
                case .studentRent:
                    apartmentTypeRow.valueSignal.value = String(key: .MY_HOME_ROW_TYPE_RENTAL_VALUE)
                case .__unknown:
                    apartmentTypeRow.valueSignal.value = String(key: .GENERIC_UNKNOWN)
                }
            }
            innerBag += sectionView.append(apartmentTypeRow)
            }
            return innerBag
        }
                    
        return (sectionView, bag)
    }
}
