//
//  InsuranceSummarySection.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-03.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct InsuranceSummarySection {
    @Inject var client: ApolloClient
    let headerView: UIView?
    let footerView: UIView?

    init(
        headerView: UIView? = nil,
        footerView: UIView? = nil
    ) {
        self.headerView = headerView
        self.footerView = footerView
    }
}

extension InsuranceSummarySection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
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
                                
                if let ancillaryArea = insurance.ancillaryArea {
                    let ancillaryAreaRow = KeyValueRow()
                    ancillaryAreaRow.keySignal.value = String(key: .MY_HOME_ROW_ANCILLARY_AREA_KEY)
                    ancillaryAreaRow.valueSignal.value = String(key: .MY_HOME_ROW_ANCILLARY_AREA_VALUE(
                        area: String(ancillaryArea)
                    ))
                    ancillaryAreaRow.valueStyleSignal.value = .rowTitleDisabled
                    innerBag += sectionView.append(ancillaryAreaRow)
                }
                
                if let yearOfConstruction = insurance.yearOfConstruction {
                    let yearOfConstructionRow = KeyValueRow()
                    yearOfConstructionRow.keySignal.value = String(key: .MY_HOME_ROW_ANCILLARY_AREA_KEY)
                    yearOfConstructionRow.valueSignal.value = String(yearOfConstruction)
                    yearOfConstructionRow.valueStyleSignal.value = .rowTitleDisabled
                    innerBag += sectionView.append(yearOfConstructionRow)
                }
                
                if let numberOfBathrooms = insurance.numberOfBathrooms {
                    let numberOfBathroomsRow = KeyValueRow()
                    numberOfBathroomsRow.keySignal.value = String(key: .MY_HOME_ROW_BATHROOMS_KEY)
                    numberOfBathroomsRow.valueSignal.value = String(numberOfBathrooms)
                    numberOfBathroomsRow.valueStyleSignal.value = .rowTitleDisabled
                    innerBag += sectionView.append(numberOfBathroomsRow)
                }
                
                if let extraBuildings = insurance.extraBuildings {
                    let extraBuildingsSection = SectionView(
                        headerView: UILabel(value: String(key: .MY_HOME_EXTRABUILDING_TITLE), style: .rowTitle),
                        footerView: nil
                    )
                    sectionView.append(extraBuildingsSection)
                    
                    innerBag += extraBuildings.map { extraBuilding in
                        ExtraBuildingRow(data: .static(extraBuilding))
                    }.map { extraBuildingRow in
                        extraBuildingsSection.append(extraBuildingRow)
                    }
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
                    case .house:
                        apartmentTypeRow.valueSignal.value = String(key: .MY_HOME_ROW_TYPE_HOUSE_VALUE)
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
