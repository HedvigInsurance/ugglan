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
    let changedDataSignal: ReadWriteSignal<Bool>

    init(referredBySignal: ReadSignal<InvitationsListRow?>, invitationsSignal: ReadSignal<[InvitationsListRow]?>, changedDataSignal: ReadWriteSignal<Bool> = ReadWriteSignal<Bool>(false)) {
        self.referredBySignal = referredBySignal
        self.invitationsSignal = invitationsSignal
        self.changedDataSignal = changedDataSignal
    }
}

extension ReferralsInvitationsTable: Viewable {
    func materialize(events _: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()

        let tableStyle = DynamicTableViewFormStyle.grouped.restyledWithStyleAndInput { (style: inout TableViewFormStyle, trait) in
            style.section.minRowHeight = 72
            style.form.insets = UIEdgeInsets(horizontalInset: 0, verticalInset: 0)

            style.section.background = trait.userInterfaceStyle == .dark ?
                               SectionStyle.Background.standardDarkLargeIconsRoundedBorder :
                               SectionStyle.Background.standardLightLargeIconsRoundedBorder
        }

        let tableKit = TableKit<String, InvitationsListRow>(
            table: Table<String, InvitationsListRow>.init(),
            style: tableStyle,
            holdIn: bag,
            headerForSection: { _, title in
                let headerStackView = UIStackView()
                headerStackView.edgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0)
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

        bag += combineLatest(invitationsSignal.atOnce().compactMap { $0 }.map { rows -> [InvitationsListRow] in
            if rows.isEmpty {
                return [.right(ReferralsInvitationAnonymous(count: nil))]
            }

            return rows
        }, referredBySignal.atOnce().plain()).map { rows, referredBy -> Table<String, InvitationsListRow> in
            let rowsSection = (String(key: .REFERRAL_INVITE_TITLE), rows)

            if let referredBy = referredBy {
                return Table(sections: [(String(key: .REFERRAL_REFERRED_BY_TITLE), [referredBy]), rowsSection])
            }

            return Table(sections: [rowsSection])
        }.onValue { table in
            tableKit.table = table
            self.changedDataSignal.value = true
        }

        return (tableKit.view, bag)
    }
}
