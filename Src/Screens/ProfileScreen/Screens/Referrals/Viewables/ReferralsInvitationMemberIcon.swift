//
//  ReferralsInvitationMemberIcon.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-03.
//

import Foundation
import Flow
import UIKit
import Form

struct ReferralsInvitationMemberIcon {}

extension ReferralsInvitationMemberIcon: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        
        let styling = UIView()
        styling.backgroundColor = UIColor.lightGray
        styling.layer.cornerRadius = 8
        
        view.addArrangedSubview(styling)
        
        styling.snp.makeConstraints { make in
            make.height.equalTo(28)
        }
        
        let contentView = UIStackView()
        contentView.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 6)
        contentView.isLayoutMarginsRelativeArrangement = true
        
        styling.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }
        
        let amountLabel = UILabel(value: "-10kr", style: TextStyle.bodyOffBlack.lineHeight(1.7))
        contentView.addArrangedSubview(amountLabel)
        
        let checkmarkIcon = Icon(icon: Asset.greenCircularCheckmark, iconWidth: 16)
        contentView.addArrangedSubview(checkmarkIcon)
        
        checkmarkIcon.snp.makeConstraints { make in
            make.width.equalTo(16)
        }
        
        return (view, NilDisposer())
    }
}
