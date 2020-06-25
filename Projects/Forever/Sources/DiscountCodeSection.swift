//
//  DiscountCodeSection.swift
//  Forever
//
//  Created by sam on 8.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct DiscountCodeSection {
    let discountCodeSignal: ReadSignal<String?>
}

extension DiscountCodeSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(
            headerView: UILabel(value: L10n.ReferralsEmpty.Code.headline, style: .default),
            footerView: {
                let stackView = UIStackView()

                let label = MultilineLabel(
                    value: L10n.ReferralsEmpty.Code.footer,
                    style: TextStyle.brand(.footnote(color: .tertiary)).aligned(to: .center)
                )

                bag += stackView.addArranged(label)

                return stackView
            }()
        )
        section.isHidden = true

        let codeRow = RowView()
        codeRow.accessibilityLabel = L10n.referralsDiscountCodeAccessibility
        let codeLabel = UILabel(
            value: "",
            style: TextStyle.brand(.title3(color: .primary)).centerAligned
        )
        codeRow.append(codeLabel)

        bag += discountCodeSignal.atOnce().compactMap { $0 }.animated(style: SpringAnimationStyle.lightBounce()) { code in
            section.animationSafeIsHidden = false
            codeLabel.value = code
        }
        
        bag += section.append(codeRow).trackedSignal.onValue { _ in
            section.viewController?.presentConditionally(PushNotificationReminder(), style: .modal).onResult { _ in
                UIPasteboard.general.string = self.discountCodeSignal.value ?? ""
                bag += section.viewController?.displayToast(title: L10n.ReferralsActiveToast.text)
            }
        }

        return (section, bag)
    }
}
