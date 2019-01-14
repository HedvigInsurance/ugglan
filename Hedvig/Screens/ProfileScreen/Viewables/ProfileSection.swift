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

        return (section, bag)
    }
}
