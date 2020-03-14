//
//  ReferralsInvitationMemberIcon.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-03.
//

import Flow
import Form
import Foundation
import UIKit

struct ReferralsInvitationMemberIcon {}

extension ReferralsInvitationMemberIcon: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center

        let boxView = UIView()
        boxView.backgroundColor = UIColor.primaryBackground
        boxView.layer.cornerRadius = 8

        view.addArrangedSubview(boxView)

        boxView.snp.makeConstraints { make in
            make.height.equalTo(28)
        }

        let contentView = UIStackView()
        contentView.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 6)
        contentView.isLayoutMarginsRelativeArrangement = true

        boxView.addSubview(contentView)

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
