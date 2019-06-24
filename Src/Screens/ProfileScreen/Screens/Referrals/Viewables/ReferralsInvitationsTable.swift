//
//  Referra,s.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-03.
//

import Flow
import Form
import Foundation
import Presentation

typealias InvitationsListRow = Either<ReferralsInvitation, ReferralsInvitationAnonymous>

struct ReferralsInvitationsTable {
    let invitationsSignal: Signal<[InvitationsListRow]>
}

extension ReferralsInvitationsTable: Viewable {
    func materialize(events _: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()

        let tableStyle = DynamicTableViewFormStyle.grouped.restyled { (style: inout TableViewFormStyle) in
            style.section.minRowHeight = 72
            style.section.background = SectionStyle.Background.standardLargeIcons
        }

        let tableKit = TableKit<EmptySection, InvitationsListRow>(
            table: Table(rows: []),
            style: tableStyle,
            bag: bag,
            headerForSection: { _, _ in
                let headerStackView = UIStackView()
                headerStackView.edgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 0)
                headerStackView.isLayoutMarginsRelativeArrangement = true

                let label = UILabel(
                    value: String(key: .REFERRAL_INVITE_TITLE),
                    style: .sectionHeader
                )

                headerStackView.addArrangedSubview(label)

                return headerStackView
            }
        )
        
        tableKit.view.isScrollEnabled = false
        
        bag += invitationsSignal.map { rows in Table<EmptySection, InvitationsListRow>(rows: rows) }.onValue { table in          tableKit.view.isHidden = table.count == 0
            tableKit.table = table
        }

        return (tableKit.view, bag)
    }
}
