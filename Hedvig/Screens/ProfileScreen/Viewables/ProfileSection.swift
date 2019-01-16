//
//  ProfileRows.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

struct ProfileSection {
    let data: ProfileQuery.Data?
    let presentingViewController: UIViewController
}

extension ProfileSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(header: nil, footer: nil, style: .sectionPlain)

        let myInfoRow = MyInfoRow(
            firstName: data?.member.firstName ?? "",
            lastName: data?.member.lastName ?? "",
            presentingViewController: presentingViewController
        )

        bag += section.append(myInfoRow) { row in
            bag += myInfoRow.registerPreview(row.viewRepresentation)
        }

        let myCharityRow = MyCharityRow(
            charityName: data?.cashback.name ?? ""
        )

        bag += section.append(myCharityRow)

        let myPaymentRow = MyPaymentRow(
            monthlyCost: data?.insurance.monthlyCost ?? Int(0),
            presentingViewController: presentingViewController
        )

        bag += section.append(myPaymentRow) { row in
            bag += myPaymentRow.registerPreview(row.viewRepresentation)
        }

        return (section, bag)
    }
}
