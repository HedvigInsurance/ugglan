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

struct ReferralsInvitation: Reusable {
    enum InviteState {
        case onboarding, member, left
    }
    
    let name: String?
    let state: InviteState
    
    static func makeAndConfigure() -> (make: UIView, configure: (ReferralsInvitation) -> Disposable) {
        let view = UIStackView()
        
        let circleContainer = UIStackView()
        circleContainer.alignment = .leading
        circleContainer.axis = .vertical
        
        view.addArrangedSubview(circleContainer)
        
        let circleSize = 32
        
        let circle = UIView()
        circleContainer.addArrangedSubview(circle)
        circle.layer.cornerRadius = CGFloat(circleSize / 2)
        
        circle.snp.makeConstraints { make in
            make.width.equalTo(circleSize)
            make.height.equalTo(circleSize)
        }
        
        let circleLabel = UILabel()
        circle.addSubview(circleLabel)
        
        circleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        let contentContainer = UIStackView()
        
        let titleLabel = UILabel(value: "", style: .rowTitle)
        contentContainer.addArrangedSubview(titleLabel)
        
        view.addArrangedSubview(contentContainer)
        
        return (view, { invitation in
            let textStyle = TextStyle(
                font: HedvigFonts.circularStdBold!,
                color: UIColor.white
            ).resized(to: 16).lineHeight(20).centerAligned
            
            if let name = invitation.name {
                circleLabel.styledText = StyledText(text: String(name.prefix(1)), style: textStyle)
                circle.backgroundColor = String(name.prefix(1)).hedvigColor
                titleLabel.text = name
            }
            
            return NilDisposer()
        })
    }
}

extension ReferralsInvitationsTable: Viewable {
    func materialize(events: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()
        
        let invitations = [
            ReferralsInvitation(name: "Sam", state: .onboarding),
            ReferralsInvitation(name: "Anton", state: .onboarding),
            ReferralsInvitation(name: "Fredrik", state: .left)
        ]
        
        let tableStyle = DynamicTableViewFormStyle.grouped.restyled { (style: inout TableViewFormStyle) in
            style.section.minRowHeight = 32
            style.section.background = SectionStyle.Background.standardMediumIcons
        }
        
        let tableKit = TableKit<EmptySection, ReferralsInvitation>(table: Table(rows: invitations), style: tableStyle, bag: bag)
        tableKit.view.isScrollEnabled = false
        
        return (tableKit.view, bag)
    }
}
