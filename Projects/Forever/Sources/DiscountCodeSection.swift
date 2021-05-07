import Flow
import Form
import Foundation
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
				stackView.axis = .horizontal

				let label = UILabel(value: L10n.ReferralsEmpty.Code.headline, style: .default)
				stackView.addArrangedSubview(label)

				let changeButton = Button(
					title: L10n.ReferralsEmpty.Edit.Code.button,
					type: .outline(borderColor: .clear, textColor: .brand(.link))
				)

				bag += changeButton.onTapSignal.onValue { _ in
					stackView.viewController?.present(
						ChangeCode(service: self.service),
						style: .modal
					)
				}

				bag += stackView.addArranged(changeButton.wrappedIn(UIStackView()))

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

		let codeRow = RowView()
		codeRow.accessibilityLabel = L10n.referralsDiscountCodeAccessibility
		let codeLabel = UILabel(value: "", style: TextStyle.brand(.title3(color: .primary)).centerAligned)
		codeRow.append(codeLabel)

		bag += service.dataSignal.atOnce().compactMap { $0?.discountCode }.animated(
			style: SpringAnimationStyle.lightBounce()
		) { code in section.animationSafeIsHidden = false
			codeLabel.value = code
		}

		bag += section.append(codeRow).trackedSignal.onValueDisposePrevious { _ in let innerBag = DisposeBag()

			section.viewController?.presentConditionally(PushNotificationReminder(), style: .modal).onResult
			{ _ in
				innerBag += self.service.dataSignal.atOnce().compactMap { $0?.discountCode }.bindTo(
					UIPasteboard.general,
					\.string
				)
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
