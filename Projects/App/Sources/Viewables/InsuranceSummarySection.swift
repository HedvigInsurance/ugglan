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
import hCore
import hCoreUI
import hGraphQL
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

        let containerView = UIView()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10

        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let sectionView = SectionView(
            headerView: headerView,
            footerView: footerView
        )
        sectionView.dynamicStyle = .sectionPlain

        stackView.addArrangedSubview(sectionView)

        bag += client.watch(query: GraphQL.MyHomeQuery()).onValueDisposePrevious { data in
            let innerBag = DisposeBag()

            let insurance = data.insurance

            if let livingSpace = insurance.livingSpace {
                let livingSpaceRow = KeyValueRow()
                livingSpaceRow.keySignal.value = L10n.myHomeRowSizeKey
                livingSpaceRow.valueSignal.value = L10n.myHomeRowSizeValue(String(livingSpace))
                livingSpaceRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
                innerBag += sectionView.append(livingSpaceRow)
            }

            if let ancillaryArea = insurance.ancillaryArea {
                let ancillaryAreaRow = KeyValueRow()
                ancillaryAreaRow.keySignal.value = L10n.myHomeRowAncillaryAreaKey
                ancillaryAreaRow.valueSignal.value = L10n.myHomeRowAncillaryAreaValue(String(ancillaryArea))
                ancillaryAreaRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
                innerBag += sectionView.append(ancillaryAreaRow)
            }

            if let yearOfConstruction = insurance.yearOfConstruction {
                let yearOfConstructionRow = KeyValueRow()
                yearOfConstructionRow.keySignal.value = L10n.myHomeRowConstructionYearKey
                yearOfConstructionRow.valueSignal.value = String(yearOfConstruction)
                yearOfConstructionRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
                innerBag += sectionView.append(yearOfConstructionRow)
            }

            if let numberOfBathrooms = insurance.numberOfBathrooms {
                let numberOfBathroomsRow = KeyValueRow()
                numberOfBathroomsRow.keySignal.value = L10n.myHomeRowBathroomsKey
                numberOfBathroomsRow.valueSignal.value = String(numberOfBathrooms)
                numberOfBathroomsRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
                innerBag += sectionView.append(numberOfBathroomsRow)
            }

            if let isSubleted = insurance.isSubleted {
                let isSubletedRow = KeyValueRow()
                isSubletedRow.keySignal.value = L10n.myHomeRowSubletedKey
                isSubletedRow.valueSignal.value = isSubleted ?
                    L10n.myHomeRowSubletedValueYes :
                    L10n.myHomeRowSubletedValueNo
                isSubletedRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
                innerBag += sectionView.append(isSubletedRow)
            }

            let adressRow = KeyValueRow()
            adressRow.keySignal.value = L10n.myHomeAddressRowKey
            adressRow.valueSignal.value = insurance.address ?? ""
            adressRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            innerBag += sectionView.append(adressRow)

            let postalCodeRow = KeyValueRow()
            postalCodeRow.keySignal.value = L10n.myHomeRowPostalCodeKey
            postalCodeRow.valueSignal.value = insurance.postalNumber ?? ""
            postalCodeRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            innerBag += sectionView.append(postalCodeRow)

            let apartmentTypeRow = KeyValueRow()
            apartmentTypeRow.keySignal.value = L10n.myHomeRowTypeKey
            apartmentTypeRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))

            if let insuranceType = insurance.type {
                switch insuranceType {
                case .brf:
                    apartmentTypeRow.valueSignal.value = L10n.myHomeRowTypeCondominiumValue
                case .studentBrf:
                    apartmentTypeRow.valueSignal.value = L10n.myHomeRowTypeCondominiumValue
                case .rent:
                    apartmentTypeRow.valueSignal.value = L10n.myHomeRowTypeRentalValue
                case .studentRent:
                    apartmentTypeRow.valueSignal.value = L10n.myHomeRowTypeRentalValue
                case .house:
                    apartmentTypeRow.valueSignal.value = L10n.myHomeRowTypeHouseValue
                case .__unknown:
                    apartmentTypeRow.valueSignal.value = L10n.genericUnknown
                }
            }
            innerBag += sectionView.append(apartmentTypeRow)

            if let extraBuildings = insurance.extraBuildings, !extraBuildings.isEmpty {
                let extraBuildingsSection = SectionView(
                    headerView: UILabel(value: L10n.myHomeExtrabuildingTitle, style: .rowTitle),
                    footerView: nil
                )
                extraBuildingsSection.dynamicStyle = .sectionPlain

                stackView.addArrangedSubview(extraBuildingsSection)

                innerBag += {
                    extraBuildingsSection.removeFromSuperview()
                }

                innerBag += extraBuildings.map { extraBuilding in
                    ExtraBuildingRow(data: .static(extraBuilding.fragments.extraBuildingFragment))
                }.map { extraBuildingRow in
                    extraBuildingsSection.append(extraBuildingRow)
                }
            }

            return innerBag
        }

        return (containerView, bag)
    }
}
