//
//  InvitationRow.swift
//  Forever
//
//  Created by sam on 2.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit
import hCore

struct InvitationRow: Hashable {
    let name: String
    let state: State
    let discount: MonetaryAmount
    
    enum State {
        case terminated
        case pending
        case active
    }
}

extension InvitationRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (InvitationRow) -> Disposable) {
        let stackView = UIStackView()
        
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFill
        stackView.addArrangedSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(18)
        }
        
        let nameLabel = UILabel(value: "", style: .brand(.headline(color: .primary)))
        stackView.addArrangedSubview(nameLabel)
        
        let discountAmountLabel = UILabel(value: "", style: .brand(.headline(color: .primary)))
        stackView.addArrangedSubview(discountAmountLabel)

        return (stackView, { `self` in
            nameLabel.value = self.name
            
            switch self.state {
            case .active:
                iconImageView.image = Asset.activeInvite.image
                discountAmountLabel.value = self.discount.formattedAmount
                discountAmountLabel.style = .brand(.headline(color: .primary))
            case .pending:
                iconImageView.image = Asset.pendingInvite.image
                discountAmountLabel.value = L10n.ReferallsInviteeStates.awaiting
                discountAmountLabel.style = .brand(.headline(color: .tertiary))
            case .terminated:
                iconImageView.image = Asset.terminatedInvite.image
                iconImageView.tintColor = .brand(.regularCaution)
                discountAmountLabel.value = L10n.ReferallsInviteeStates.terminated
                discountAmountLabel.style = .brand(.headline(color: .destructive))
            }
            
            return NilDisposer()
        })
    }
}
