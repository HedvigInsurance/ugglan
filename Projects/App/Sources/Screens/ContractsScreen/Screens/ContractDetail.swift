//
//  ContractDetail.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-18.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit
import Core

struct ContractDetail {
    let contract: ContractsQuery.Data.Contract
}

extension ContractDetail: Presentable {
    func swedishApartment() -> (DisposeBag, [Either<SectionView, Spacing>])? {
        if let swedishApartment = contract.currentAgreement.asSwedishApartmentAgreement {
            let bag = DisposeBag()
            let apartmentInfoSection = SectionView()
            apartmentInfoSection.dynamicStyle = .sectionPlain

            let livingSpaceRow = KeyValueRow()
            livingSpaceRow.keySignal.value = L10n.myHomeRowSizeKey
            livingSpaceRow.valueSignal.value = L10n.myHomeRowSizeValue(String(swedishApartment.squareMeters))
            livingSpaceRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(livingSpaceRow)

            let adressRow = KeyValueRow()
            adressRow.keySignal.value = L10n.myHomeAddressRowKey
            adressRow.valueSignal.value = swedishApartment.address.street
            adressRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(adressRow)

            let postalCodeRow = KeyValueRow()
            postalCodeRow.keySignal.value = L10n.myHomeRowPostalCodeKey
            postalCodeRow.valueSignal.value = swedishApartment.address.postalCode
            postalCodeRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(postalCodeRow)

            let apartmentTypeRow = KeyValueRow()
            apartmentTypeRow.keySignal.value = L10n.myHomeRowTypeKey
            apartmentTypeRow.valueStyleSignal.value = .rowTitleDisabled

            switch swedishApartment.type {
            case .brf:
                apartmentTypeRow.valueSignal.value = L10n.myHomeRowTypeCondominiumValue
            case .studentBrf:
                apartmentTypeRow.valueSignal.value = L10n.myHomeRowTypeCondominiumValue
            case .rent:
                apartmentTypeRow.valueSignal.value = L10n.myHomeRowTypeRentalValue
            case .studentRent:
                apartmentTypeRow.valueSignal.value = L10n.myHomeRowTypeRentalValue
            case .__unknown:
                apartmentTypeRow.valueSignal.value = L10n.genericUnknown
            }
            bag += apartmentInfoSection.append(apartmentTypeRow)

            let coinsuredSection = SectionView()
            coinsuredSection.dynamicStyle = .sectionPlain

            let coinsuredRow = KeyValueRow()
            coinsuredRow.keySignal.value = L10n.contractDetailCoinsuredTitle
            coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInput(swedishApartment.numberCoInsured)
            coinsuredRow.valueStyleSignal.value = .rowTitleDisabled
            bag += coinsuredSection.append(coinsuredRow)

            return (bag, [
                .make(apartmentInfoSection),
                .make(Spacing(height: 10)),
                .make(coinsuredSection),
            ])
        }

        return nil
    }

    func swedishHouse() -> (DisposeBag, [Either<SectionView, Spacing>])? {
        if let swedishHouse = contract.currentAgreement.asSwedishHouseAgreement {
            let bag = DisposeBag()

            let apartmentInfoSection = SectionView()
            apartmentInfoSection.dynamicStyle = .sectionPlain

            let livingSpaceRow = KeyValueRow()
            livingSpaceRow.keySignal.value = L10n.myHomeRowSizeKey
            livingSpaceRow.valueSignal.value = L10n.myHomeRowSizeValue(String(swedishHouse.squareMeters))
            livingSpaceRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(livingSpaceRow)

            let ancillaryAreaRow = KeyValueRow()
            ancillaryAreaRow.keySignal.value = L10n.myHomeRowAncillaryAreaKey
            ancillaryAreaRow.valueSignal.value = L10n.myHomeRowAncillaryAreaValue(String(swedishHouse.ancillaryArea))
            ancillaryAreaRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(ancillaryAreaRow)

            let yearOfConstructionRow = KeyValueRow()
            yearOfConstructionRow.keySignal.value = L10n.myHomeRowConstructionYearKey
            yearOfConstructionRow.valueSignal.value = String(swedishHouse.yearOfConstruction)
            yearOfConstructionRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(yearOfConstructionRow)

            let numberOfBathroomsRow = KeyValueRow()
            numberOfBathroomsRow.keySignal.value = L10n.myHomeRowBathroomsKey
            numberOfBathroomsRow.valueSignal.value = String(swedishHouse.numberOfBathrooms)
            numberOfBathroomsRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(numberOfBathroomsRow)

            let isSubletedRow = KeyValueRow()
            isSubletedRow.keySignal.value = L10n.myHomeRowSubletedKey
            isSubletedRow.valueSignal.value = swedishHouse.isSubleted ?
                L10n.myHomeRowSubletedValueYes :
                L10n.myHomeRowSubletedValueNo
            isSubletedRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(isSubletedRow)

            let adressRow = KeyValueRow()
            adressRow.keySignal.value = L10n.myHomeAddressRowKey
            adressRow.valueSignal.value = swedishHouse.address.street
            adressRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(adressRow)

            let postalCodeRow = KeyValueRow()
            postalCodeRow.keySignal.value = L10n.myHomeRowPostalCodeKey
            postalCodeRow.valueSignal.value = swedishHouse.address.postalCode
            postalCodeRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(postalCodeRow)

            let apartmentTypeRow = KeyValueRow()
            apartmentTypeRow.keySignal.value = L10n.myHomeRowTypeKey
            apartmentTypeRow.valueStyleSignal.value = .rowTitleDisabled
            apartmentTypeRow.valueSignal.value = L10n.myHomeRowTypeHouseValue
            bag += apartmentInfoSection.append(apartmentTypeRow)

            if !swedishHouse.extraBuildings.isEmpty {
                let extraBuildingsSection = SectionView(
                    headerView: UILabel(value: L10n.myHomeExtrabuildingTitle, style: .rowTitle),
                    footerView: nil
                )
                extraBuildingsSection.dynamicStyle = .sectionPlain

                bag += swedishHouse.extraBuildings.compactMap { $0 }.map { extraBuilding in
                    extraBuildingsSection.append(
                        ExtraBuildingRow(data: .static(extraBuilding.fragments.extraBuildingFragment))
                    )
                }

                return (bag, [
                    .make(apartmentInfoSection),
                    .make(Spacing(height: 10)),
                    .make(extraBuildingsSection),
                ])
            } else {
                return (bag, [
                    .make(apartmentInfoSection),
                ])
            }
        }

        return nil
    }

    func norwegianHomeContents() -> (DisposeBag, [Either<SectionView, Spacing>])? {
        if let norwegianHomeContents = contract.currentAgreement.asNorwegianHomeContentAgreement {
            let bag = DisposeBag()
            let apartmentInfoSection = SectionView()
            apartmentInfoSection.dynamicStyle = .sectionPlain

            let livingSpaceRow = KeyValueRow()
            livingSpaceRow.keySignal.value = L10n.myHomeRowSizeKey
            livingSpaceRow.valueSignal.value = L10n.myHomeRowSizeValue(String(norwegianHomeContents.squareMeters))
            livingSpaceRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(livingSpaceRow)

            let adressRow = KeyValueRow()
            adressRow.keySignal.value = L10n.myHomeAddressRowKey
            adressRow.valueSignal.value = norwegianHomeContents.address.street
            adressRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(adressRow)

            let postalCodeRow = KeyValueRow()
            postalCodeRow.keySignal.value = L10n.myHomeRowPostalCodeKey
            postalCodeRow.valueSignal.value = norwegianHomeContents.address.postalCode
            postalCodeRow.valueStyleSignal.value = .rowTitleDisabled
            bag += apartmentInfoSection.append(postalCodeRow)

            let coinsuredSection = SectionView()
            coinsuredSection.dynamicStyle = .sectionPlain

            let coinsuredRow = KeyValueRow()
            coinsuredRow.keySignal.value = L10n.contractDetailCoinsuredTitle

            if norwegianHomeContents.numberCoInsured > 0 {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInput(norwegianHomeContents.numberCoInsured)
            } else {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInputZeroCoinsured
            }

            coinsuredRow.valueStyleSignal.value = .rowTitleDisabled
            bag += coinsuredSection.append(coinsuredRow)

            return (bag, [
                .make(apartmentInfoSection),
                .make(Spacing(height: 10)),
                .make(coinsuredSection),
            ])
        }

        return nil
    }

    func norwegianTravel() -> (DisposeBag, [Either<SectionView, Spacing>])? {
        if let norwegianTravel = contract.currentAgreement.asNorwegianTravelAgreement {
            let bag = DisposeBag()

            let coinsuredSection = SectionView()
            coinsuredSection.dynamicStyle = .sectionPlain

            let coinsuredRow = KeyValueRow()
            coinsuredRow.keySignal.value = L10n.contractDetailCoinsuredTitle

            if norwegianTravel.numberCoInsured > 0 {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInput(norwegianTravel.numberCoInsured)
            } else {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInputZeroCoinsured
            }

            coinsuredRow.valueStyleSignal.value = .rowTitleDisabled
            bag += coinsuredSection.append(coinsuredRow)

            return (bag, [
                .make(coinsuredSection),
            ])
        }

        return nil
    }

    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.contractDetailMainTitle
        let bag = DisposeBag()

        let form = FormView()

        if let (swedishApartmentBag, swedishApartmentContent) = swedishApartment() {
            bag += swedishApartmentBag
            swedishApartmentContent.forEach { content in
                switch content {
                case let .left(section):
                    form.append(section)
                case let .right(spacing):
                    bag += form.append(spacing)
                }
            }
        }

        if let (swedishHouseBag, swedishHouseContent) = swedishHouse() {
            bag += swedishHouseBag
            swedishHouseContent.forEach { content in
                switch content {
                case let .left(section):
                    form.append(section)
                case let .right(spacing):
                    bag += form.append(spacing)
                }
            }
        }

        if let (norwegianHomeContentsBag, norwegianHomeContents) = norwegianHomeContents() {
            bag += norwegianHomeContentsBag
            norwegianHomeContents.forEach { content in
                switch content {
                case let .left(section):
                    form.append(section)
                case let .right(spacing):
                    bag += form.append(spacing)
                }
            }
        }

        if let (norwegianTravelBag, norwegianTravelContent) = norwegianTravel() {
            bag += norwegianTravelBag
            norwegianTravelContent.forEach { content in
                switch content {
                case let .left(section):
                    form.append(section)
                case let .right(spacing):
                    bag += form.append(spacing)
                }
            }
        }

        bag += form.append(Spacing(height: 20))

        let changeButton = ButtonSection(
            text: L10n.contractDetailHomeChangeInfo,
            style: .normal
        )
        bag += form.append(changeButton)

        bag += changeButton.onSelect.onValue {
            let alert = Alert<Bool>(
                title: L10n.myHomeChangeAlertTitle,
                message: L10n.myHomeChangeAlertMessage,
                actions: [
                    Alert.Action(title: L10n.myHomeChangeAlertActionCancel) { false },
                    Alert.Action(title: L10n.myHomeChangeAlertActionConfirm) { true },
                ]
            )

            viewController.present(alert).onValue { shouldContinue in
                if shouldContinue {
                    viewController.present(
                        FreeTextChat().withCloseButton,
                        style: .modally(
                            presentationStyle: .pageSheet,
                            transitionStyle: nil,
                            capturesStatusBarAppearance: true
                        )
                    )
                }
            }
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
