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
        
        var description: String {
            switch self {
            case .onboarding:
                return String(key: .REFERRAL_INVITE_STARTEDSTATE)
            case .member:
                return String(key: .REFERRAL_INVITE_NEWSTATE)
            case .left:
                return String(key: .REFERRAL_INVITE_QUITSTATE)
            }
        }
    }
    
    let name: String?
    let state: InviteState
    
    static let circleSize = 32
    
    static func makeAndConfigure() -> (make: UIView, configure: (ReferralsInvitation) -> Disposable) {
        let view = UIStackView()
        view.spacing = 12
        
        let circleContainer = UIStackView()
        circleContainer.alignment = .center
        circleContainer.axis = .horizontal
        circleContainer.snp.makeConstraints { make in
            make.width.equalTo(circleSize)
            make.height.equalTo(circleSize)
        }
        
        view.addArrangedSubview(circleContainer)
        
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
        contentContainer.axis = .vertical
        contentContainer.spacing = 5
        
        let titleLabel = UILabel(value: "", style: .rowTitleBold)
        contentContainer.addArrangedSubview(titleLabel)
        
        let descriptionLabel = UILabel(value: "", style: .rowSubtitle)
        contentContainer.addArrangedSubview(descriptionLabel)
        
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
            
            descriptionLabel.text = invitation.state.description
            
            return NilDisposer()
        })
    }
}

extension ReferralsInvitationsTable: Viewable {
    func materialize(events: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()
        
        var invitations = [
            ReferralsInvitation(name: "Sam", state: .onboarding),
            ReferralsInvitation(name: "Anton", state: .onboarding),
            ReferralsInvitation(name: "Fredrik", state: .left)
        ]
        
        for _ in 1...3 {
            invitations.forEach { invitation in
                invitations.append(invitation)
            }
        }
        
        let tableStyle = DynamicTableViewFormStyle.grouped.restyled { (style: inout TableViewFormStyle) in
            style.section.minRowHeight = 72
            style.section.background = SectionStyle.Background.standardMediumIcons
        }
        
        let tableKit = TableKit<EmptySection, ReferralsInvitation>(
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
