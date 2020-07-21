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
    var service: ForeverService
    let discountCodeSignal: ReadSignal<String?>
    let potentialDiscountAmountSignal: ReadSignal<MonetaryAmount?>
}

extension DiscountCodeSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(
            headerView: {
                let stackView = UIStackView()
                stackView.axis = .horizontal

                let label = UILabel(value: L10n.ReferralsEmpty.Code.headline, style: .default)
                stackView.addArrangedSubview(label)
                
                let changeButton = Button(
                    title: L10n.ReferralsEmpty.Edit.Code.button,
                    type: .outline(borderColor: .clear, textColor: .brand(.link))
                )
                                                
                bag += changeButton.onTapSignal.onValue { _ in
                    stackView.viewController?.present(ChangeCode(service: self.service), style: .modal)
                }
                
                bag += stackView.addArranged(changeButton.wrappedIn(UIStackView()))
                
                return stackView
            }(),
            footerView: {
                let stackView = UIStackView()

                let label = MultilineLabel(
                    value: "",
                    style: TextStyle.brand(.footnote(color: .tertiary)).aligned(to: .center)
                )
                
                bag += potentialDiscountAmountSignal.atOnce().compactMap { $0 }.onValue { monetaryAmount in
                    label.valueSignal.value = L10n.ReferralsEmpty.Code.footer(monetaryAmount.formattedAmount)
                }

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
