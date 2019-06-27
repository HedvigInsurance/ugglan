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
    let referredBySignal: ReadSignal<InvitationsListRow?>
    let invitationsSignal: ReadSignal<[InvitationsListRow]?>
}

extension ReferralsInvitationsTable: Viewable {
    func materialize(events _: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()

        let tableStyle = DynamicTableViewFormStyle.grouped.restyled { (style: inout TableViewFormStyle) in
            style.section.minRowHeight = 72
            style.section.background = SectionStyle.Background.standardLargeIcons
        }

        let tableKit = TableKit<String, InvitationsListRow>(
            table: Table<String, InvitationsListRow>.init(),
            style: tableStyle,
            bag: bag,
            headerForSection: { _, title in
                let headerStackView = UIStackView()
                headerStackView.edgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 0)
                headerStackView.isLayoutMarginsRelativeArrangement = true

                let label = UILabel(
                    value: title,
                    style: .sectionHeader
                )

                headerStackView.addArrangedSubview(label)

                return headerStackView
            }
        )

        tableKit.view.isScrollEnabled = false

        bag += invitationsSignal.compactMap { $0 }.map { rows -> [InvitationsListRow] in
            if rows.isEmpty {
                return [.right(ReferralsInvitationAnonymous(count: nil))]
            }

            return rows
        }.withLatestFrom(referredBySignal.atOnce().plain()).map { rows, referredBy -> Table<String, InvitationsListRow> in
            let rowsSection = (String(key: .REFERRAL_INVITE_TITLE), rows)

            if let referredBy = referredBy {
                return Table(sections: [(String(key: .REFERRAL_REFERRED_BY_TITLE), [referredBy]), rowsSection])
            }

            return Table(sections: [rowsSection])
        }.onValue { table in
            tableKit.table = table
        }

        return (tableKit.view, bag)
    }
}
