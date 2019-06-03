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
        
        let circleContainer = UIView()
        circleContainer.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(circleSize)
        }
        
        view.addArrangedSubview(circleContainer)
        
        let circle = UIView()
        circleContainer.addSubview(circle)
        circle.layer.cornerRadius = CGFloat(circleSize / 2)
        
        circle.snp.makeConstraints { make in
            make.width.equalTo(circleSize)
            make.height.equalTo(circleSize)
            make.center.equalToSuperview()
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
        
        let iconContainer = UIStackView()
        
        view.addArrangedSubview(iconContainer)
        
        return (view, { invitation in
            let bag = DisposeBag()
            
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
            
            iconContainer.subviews.forEach({ subview in
                subview.removeFromSuperview()
            })
            
            switch invitation.state {
            case .onboarding:
                bag += iconContainer.addArranged(ReferralsInvitationOnboardingIcon())
                
                iconContainer.snp.remakeConstraints({ make in
                    make.width.equalTo(16)
                })
                break
            case .member:
                bag += iconContainer.addArranged(ReferralsInvitationMemberIcon())
                
                iconContainer.snp.remakeConstraints({ make in
                    make.width.equalTo(76)
                })
                break
            case .left:
                bag += iconContainer.addArranged(ReferralsInvitationLeftIcon())
                
                iconContainer.snp.remakeConstraints({ make in
                    make.width.equalTo(16)
                })
                break
            }
            
            return bag
        })
    }
}

extension ReferralsInvitationsTable: Viewable {
    func materialize(events: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()
        
        var invitations = [
            ReferralsInvitation(name: "Sam", state: .onboarding),
            ReferralsInvitation(name: "Anton", state: .member),
            ReferralsInvitation(name: "Fredrik", state: .left)
        ]
        
        for _ in 1...3 {
            invitations.forEach { invitation in
                invitations.append(invitation)
            }
        }
        
        let tableStyle = DynamicTableViewFormStyle.grouped.restyled { (style: inout TableViewFormStyle) in
            style.section.minRowHeight = 72
            style.section.background = SectionStyle.Background.standardLargeIcons
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
