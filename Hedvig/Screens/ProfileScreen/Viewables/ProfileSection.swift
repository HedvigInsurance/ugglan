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
    let member: ProfileQuery.Data.Member
    let form: FormView
    let presentingViewController: UIViewController
}

extension ProfileSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(header: nil, footer: nil, style: .sectionPlain)

        let myInfoRow = MyInfoRow(
            firstName: member.firstName ?? "",
            lastName: member.lastName ?? "",
            presentingViewController: presentingViewController
        )

        bag += section.append(myInfoRow)

        return (section, bag)
    }
}
