import Flow
import Form
import Foundation
import SwiftUI
import UIKit
import hCore
import hCoreUI

struct DiscountCodeSection { var service: ForeverService }

extension DiscountCodeSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(
            headerView: {
                let stackView = UIStackView()
                stackView.distribution = .equalSpacing
                stackView.axis = .horizontal

                let label = UILabel(value: L10n.ReferralsEmpty.Code.headline, style: .default)
                stackView.addArrangedSubview(label)

                let changeButton = makeHost {
                    hText(L10n.ReferralsEmpty.Edit.Code.button)
                        .foregroundColor(hLabelColor.link)
                        .onTapGesture {
                            stackView.viewController?
                                .present(ChangeCode(service: self.service), style: .modal)
                        }
                }

                stackView.addArrangedSubview(changeButton)

                return stackView
            }(),
            footerView: {
                let stackView = UIStackView()

                var label = MultilineLabel(
                    value: "",
                    style: TextStyle.brand(.footnote(color: .tertiary)).aligned(to: .center)
                )

                bag += self.service.dataSignal.atOnce().compactMap { $0?.potentialDiscountAmount }
                    .onValue { monetaryAmount in
                        label.value = L10n.ReferralsEmpty.Code.footer(
                            monetaryAmount.formattedAmount
                        )
                    }

                bag += stackView.addArranged(label)

                return stackView
            }()
        )
        section.isHidden = true
        section.dynamicStyle = .brandGroupedInset(separatorType: .none)
            .restyled({ (style: inout SectionStyle) in
                style.insets = .zero
            })

        let codeRow = RowView()
        codeRow.accessibilityLabel = L10n.referralsDiscountCodeAccessibility
        let codeLabel = UILabel(value: "", style: TextStyle.brand(.title3(color: .primary)).centerAligned)
        codeRow.append(codeLabel)

        bag += service.dataSignal.atOnce().compactMap { $0?.discountCode }
            .animated(style: SpringAnimationStyle.lightBounce()) { code in
                section.animationSafeIsHidden = false
                codeLabel.value = code
            }

        bag += section.append(codeRow)
            .onValueDisposePrevious { _ in let innerBag = DisposeBag()

                section.viewController?.presentConditionally(PushNotificationReminder(), style: .modal)
                    .onResult { _ in
                        innerBag += self.service.dataSignal.atOnce()
                            .compactMap { $0?.discountCode }
                            .bindTo(UIPasteboard.general, \.string)
                        Toasts.shared.displayToast(
                            toast: .init(
                                symbol: .icon(Asset.toastIcon.image),
                                body: L10n.ReferralsActiveToast.text
                            )
                        )
                    }

                return innerBag
            }

        return (section, bag)
    }
}
