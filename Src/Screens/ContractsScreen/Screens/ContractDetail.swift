//
//  ContractDetail.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-18.
//

import Foundation
import Presentation
import Flow
import UIKit
import Form

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
           livingSpaceRow.keySignal.value = String(key: .MY_HOME_ROW_SIZE_KEY)
           livingSpaceRow.valueSignal.value = String(key: .MY_HOME_ROW_SIZE_VALUE(
            livingSpace: swedishApartment.squareMeters
           ))
           livingSpaceRow.valueStyleSignal.value = .rowTitleDisabled
           bag += apartmentInfoSection.append(livingSpaceRow)

                let adressRow = KeyValueRow()
                adressRow.keySignal.value = String(key: .MY_HOME_ADDRESS_ROW_KEY)
                adressRow.valueSignal.value = swedishApartment.address.street
                adressRow.valueStyleSignal.value = .rowTitleDisabled
                bag += apartmentInfoSection.append(adressRow)

                let postalCodeRow = KeyValueRow()
                postalCodeRow.keySignal.value = String(key: .MY_HOME_ROW_POSTAL_CODE_KEY)
            postalCodeRow.valueSignal.value = swedishApartment.address.postalCode
                postalCodeRow.valueStyleSignal.value = .rowTitleDisabled
                bag += apartmentInfoSection.append(postalCodeRow)

                let apartmentTypeRow = KeyValueRow()
                apartmentTypeRow.keySignal.value = String(key: .MY_HOME_ROW_TYPE_KEY)
                apartmentTypeRow.valueStyleSignal.value = .rowTitleDisabled

            switch swedishApartment.type {
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
                bag += apartmentInfoSection.append(apartmentTypeRow)
            
            let coinsuredSection = SectionView()
            coinsuredSection.dynamicStyle = .sectionPlain
            
            let coinsuredRow = KeyValueRow()
            coinsuredRow.keySignal.value = String(key: .CONTRACT_DETAIL_COINSURED_TITLE)
            coinsuredRow.valueSignal.value = String(key: .CONTRACT_DETAIL_COINSURED_NUMBER_INPUT(coinsured: swedishApartment.numberCoInsured))
            coinsuredRow.valueStyleSignal.value = .rowTitleDisabled
            bag += coinsuredSection.append(coinsuredRow)
            
            
            return (bag, [
                .make(apartmentInfoSection),
                .make(Spacing(height: 10)),
                .make(coinsuredSection)
            ])
        }
        
        return nil
    }
    
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = String(key: .CONTRACT_DETAIL_MAIN_TITLE)
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
        
        bag += form.append(Spacing(height: 20))
        
        let changeButton = ButtonSection(
            text: String(key: .MY_HOME_CHANGE_INFO_BUTTON),
            style: .normal
        )
        bag += form.append(changeButton)

        bag += changeButton.onSelect.onValue {
            let alert = Alert<Bool>(
                title: String(key: .MY_HOME_CHANGE_ALERT_TITLE),
                message: String(key: .MY_HOME_CHANGE_ALERT_MESSAGE),
                actions: [
                    Alert.Action(title: String(key: .MY_HOME_CHANGE_ALERT_ACTION_CANCEL)) { false },
                    Alert.Action(title: String(key: .MY_HOME_CHANGE_ALERT_ACTION_CONFIRM)) { true },
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
