//
//  ContactDetailsSection.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Core

struct ContactDetailsSection {
    let state: MyInfoState
}

extension ContactDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: L10n.myInfoContactDetailsTitle,
            footer: nil,
            style: .sectionPlain
        )

        let phoneNumberRow = PhoneNumberRow(
            state: state
        )
        bag += section.append(phoneNumberRow)

        let emailRow = EmailRow(
            state: state
        )
        bag += section.append(emailRow)

        return (section, bag)
    }
}
