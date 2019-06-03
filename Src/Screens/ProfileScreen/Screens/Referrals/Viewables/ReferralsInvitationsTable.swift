//
//  Referra,s.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-03.
//

import Foundation
import Flow
import Presentation
import Form

struct ReferralsInvitationsTable {}

extension ReferralsInvitationsTable: Viewable {
    func materialize(events: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()
        
        let invitations: [Either<ReferralsInvitation, ReferralsInvitationAnonymous>] = [
            .right(ReferralsInvitationAnonymous(count: 1)),
            .left(ReferralsInvitation(name: "Sam", state: .onboarding)),
            .left(ReferralsInvitation(name: "Anton", state: .member)),
            .left(ReferralsInvitation(name: "Fredrik", state: .left))
        ]
        
        let tableStyle = DynamicTableViewFormStyle.grouped.restyled { (style: inout TableViewFormStyle) in
            style.section.minRowHeight = 72
            style.section.background = SectionStyle.Background.standardLargeIcons
        }
        
        let tableKit = TableKit<EmptySection, Either<ReferralsInvitation, ReferralsInvitationAnonymous>>(
            table: Table(rows: invitations),
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
        
        return (tableKit.view, bag)
    }
}
