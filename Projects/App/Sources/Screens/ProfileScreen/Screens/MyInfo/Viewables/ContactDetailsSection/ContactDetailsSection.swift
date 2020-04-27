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

struct ContactDetailsSection {
    let state: MyInfoState
}

extension ContactDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: String(key: .MY_INFO_CONTACT_DETAILS_TITLE),
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
