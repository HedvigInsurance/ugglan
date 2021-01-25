import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct ContractInformation {
    let contract: GraphQL.ContractsQuery.Data.Contract
}

extension ContractInformation: Presentable {
    func swedishApartment() -> (DisposeBag, [Either<SectionView, Spacing>])? {
        if let swedishApartment = contract.currentAgreement.asSwedishApartmentAgreement {
            let bag = DisposeBag()
            let apartmentInfoSection = SectionView()

            let livingSpaceRow = KeyValueRow()
            livingSpaceRow.keySignal.value = L10n.myHomeRowSizeKey
            livingSpaceRow.valueSignal.value = L10n.myHomeRowSizeValue(String(swedishApartment.squareMeters))
            livingSpaceRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(livingSpaceRow)

            let adressRow = KeyValueRow()
            adressRow.keySignal.value = L10n.myHomeAddressRowKey
            adressRow.valueSignal.value = swedishApartment.address.street
            adressRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(adressRow)

            let postalCodeRow = KeyValueRow()
            postalCodeRow.keySignal.value = L10n.myHomeRowPostalCodeKey
            postalCodeRow.valueSignal.value = swedishApartment.address.postalCode
            postalCodeRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(postalCodeRow)

            let apartmentTypeRow = KeyValueRow()
            apartmentTypeRow.keySignal.value = L10n.myHomeRowTypeKey
            apartmentTypeRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))

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

            let coinsuredRow = KeyValueRow()
            coinsuredRow.keySignal.value = L10n.contractDetailCoinsuredTitle
            coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInput(swedishApartment.numberCoInsured)
            coinsuredRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
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

            let livingSpaceRow = KeyValueRow()
            livingSpaceRow.keySignal.value = L10n.myHomeRowSizeKey
            livingSpaceRow.valueSignal.value = L10n.myHomeRowSizeValue(String(swedishHouse.squareMeters))
            livingSpaceRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(livingSpaceRow)

            let ancillaryAreaRow = KeyValueRow()
            ancillaryAreaRow.keySignal.value = L10n.myHomeRowAncillaryAreaKey
            ancillaryAreaRow.valueSignal.value = L10n.myHomeRowAncillaryAreaValue(String(swedishHouse.ancillaryArea))
            ancillaryAreaRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(ancillaryAreaRow)

            let yearOfConstructionRow = KeyValueRow()
            yearOfConstructionRow.keySignal.value = L10n.myHomeRowConstructionYearKey
            yearOfConstructionRow.valueSignal.value = String(swedishHouse.yearOfConstruction)
            yearOfConstructionRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(yearOfConstructionRow)

            let numberOfBathroomsRow = KeyValueRow()
            numberOfBathroomsRow.keySignal.value = L10n.myHomeRowBathroomsKey
            numberOfBathroomsRow.valueSignal.value = String(swedishHouse.numberOfBathrooms)
            numberOfBathroomsRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(numberOfBathroomsRow)

            let isSubletedRow = KeyValueRow()
            isSubletedRow.keySignal.value = L10n.myHomeRowSubletedKey
            isSubletedRow.valueSignal.value = swedishHouse.isSubleted ?
                L10n.myHomeRowSubletedValueYes :
                L10n.myHomeRowSubletedValueNo
            isSubletedRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(isSubletedRow)

            let adressRow = KeyValueRow()
            adressRow.keySignal.value = L10n.myHomeAddressRowKey
            adressRow.valueSignal.value = swedishHouse.address.street
            adressRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(adressRow)

            let postalCodeRow = KeyValueRow()
            postalCodeRow.keySignal.value = L10n.myHomeRowPostalCodeKey
            postalCodeRow.valueSignal.value = swedishHouse.address.postalCode
            postalCodeRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(postalCodeRow)

            let apartmentTypeRow = KeyValueRow()
            apartmentTypeRow.keySignal.value = L10n.myHomeRowTypeKey
            apartmentTypeRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            apartmentTypeRow.valueSignal.value = L10n.myHomeRowTypeHouseValue
            bag += apartmentInfoSection.append(apartmentTypeRow)

            if !swedishHouse.extraBuildings.isEmpty {
                let extraBuildingsSection = SectionView(
                    headerView: UILabel(
                        value: L10n.myHomeExtrabuildingTitle,
                        style: .brand(.headline(color: .primary))
                    ),
                    footerView: nil
                )

                bag += swedishHouse.extraBuildings.compactMap { $0 }.map { extraBuilding in
                    extraBuildingsSection.append(
                        ExtraBuildingRow(data: ReadWriteSignal(extraBuilding.fragments.extraBuildingFragment))
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

            let livingSpaceRow = KeyValueRow()
            livingSpaceRow.keySignal.value = L10n.myHomeRowSizeKey
            livingSpaceRow.valueSignal.value = L10n.myHomeRowSizeValue(String(norwegianHomeContents.squareMeters))
            livingSpaceRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(livingSpaceRow)

            let adressRow = KeyValueRow()
            adressRow.keySignal.value = L10n.myHomeAddressRowKey
            adressRow.valueSignal.value = norwegianHomeContents.address.street
            adressRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(adressRow)

            let postalCodeRow = KeyValueRow()
            postalCodeRow.keySignal.value = L10n.myHomeRowPostalCodeKey
            postalCodeRow.valueSignal.value = norwegianHomeContents.address.postalCode
            postalCodeRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(postalCodeRow)

            let coinsuredSection = SectionView()

            let coinsuredRow = KeyValueRow()
            coinsuredRow.keySignal.value = L10n.contractDetailCoinsuredTitle

            if norwegianHomeContents.numberCoInsured > 0 {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInput(norwegianHomeContents.numberCoInsured)
            } else {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInputZeroCoinsured
            }

            coinsuredRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
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

            let coinsuredRow = KeyValueRow()
            coinsuredRow.keySignal.value = L10n.contractDetailCoinsuredTitle

            if norwegianTravel.numberCoInsured > 0 {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInput(norwegianTravel.numberCoInsured)
            } else {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInputZeroCoinsured
            }

            coinsuredRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += coinsuredSection.append(coinsuredRow)

            return (bag, [
                .make(coinsuredSection),
            ])
        }

        return nil
    }

    func danishHomeContent() -> (DisposeBag, [Either<SectionView, Spacing>])? {
        if let danishHomeContent = contract.currentAgreement.asDanishHomeContentAgreement {
            let bag = DisposeBag()
            let apartmentInfoSection = SectionView()

            let livingSpaceRow = KeyValueRow()
            livingSpaceRow.keySignal.value = L10n.myHomeRowSizeKey
            livingSpaceRow.valueSignal.value = L10n.myHomeRowSizeValue(String(danishHomeContent.squareMeters))
            livingSpaceRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(livingSpaceRow)

            let adressRow = KeyValueRow()
            adressRow.keySignal.value = L10n.myHomeAddressRowKey
            adressRow.valueSignal.value = danishHomeContent.address.street
            adressRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(adressRow)

            let postalCodeRow = KeyValueRow()
            postalCodeRow.keySignal.value = L10n.myHomeRowPostalCodeKey
            postalCodeRow.valueSignal.value = danishHomeContent.address.postalCode
            postalCodeRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += apartmentInfoSection.append(postalCodeRow)

            let coinsuredSection = SectionView()

            let coinsuredRow = KeyValueRow()
            coinsuredRow.keySignal.value = L10n.contractDetailCoinsuredTitle

            if danishHomeContent.numberCoInsured > 0 {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInput(danishHomeContent.numberCoInsured)
            } else {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInputZeroCoinsured
            }

            coinsuredRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += coinsuredSection.append(coinsuredRow)

            return (bag, [
                .make(apartmentInfoSection),
                .make(Spacing(height: 10)),
                .make(coinsuredSection),
            ])
        }

        return nil
    }

    func danishTravel() -> (DisposeBag, [Either<SectionView, Spacing>])? {
        if let danishTravel = contract.currentAgreement.asDanishTravelAgreement {
            let bag = DisposeBag()

            let coinsuredSection = SectionView()

            let coinsuredRow = KeyValueRow()
            coinsuredRow.keySignal.value = L10n.contractDetailCoinsuredTitle

            if danishTravel.numberCoInsured > 0 {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInput(danishTravel.numberCoInsured)
            } else {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInputZeroCoinsured
            }

            coinsuredRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
            bag += coinsuredSection.append(coinsuredRow)

            return (bag, [
                .make(coinsuredSection),
            ])
        }

        return nil
    }

    func danishAccident() -> (DisposeBag, [Either<SectionView, Spacing>])? {
        if let danishAccident = contract.currentAgreement.asDanishAccidentAgreement {
            let bag = DisposeBag()

            let coinsuredSection = SectionView()

            let coinsuredRow = KeyValueRow()
            coinsuredRow.keySignal.value = L10n.contractDetailCoinsuredTitle

            if danishAccident.numberCoInsured > 0 {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInput(danishAccident.numberCoInsured)
            } else {
                coinsuredRow.valueSignal.value = L10n.contractDetailCoinsuredNumberInputZeroCoinsured
            }

            coinsuredRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))
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

        if let (danishHomeContentBag, danishHomeContent) = danishHomeContent() {
            bag += danishHomeContentBag
            danishHomeContent.forEach { content in
                switch content {
                case let .left(section):
                    form.append(section)
                case let .right(spacing):
                    bag += form.append(spacing)
                }
            }
        }

        if let (danishTravelBag, danishTravelContent) = danishTravel() {
            bag += danishTravelBag
            danishTravelContent.forEach { content in
                switch content {
                case let .left(section):
                    form.append(section)
                case let .right(spacing):
                    bag += form.append(spacing)
                }
            }
        }

        if let (danishAccidentBag, danishAccidentContent) = danishAccident() {
            bag += danishAccidentBag
            danishAccidentContent.forEach { content in
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
                    Contracts.openFreeTextChatHandler(viewController)
                }
            }
        }

        bag += viewController.install(form, options: [])

        return (viewController, bag)
    }
}
