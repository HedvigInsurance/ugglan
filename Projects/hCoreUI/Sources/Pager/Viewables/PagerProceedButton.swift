import Flow
import Form
import Foundation
import UIKit
import hCore
import hGraphQL

struct PagerProceedButton {
	let buttonContinueTitle: String
	let buttonDoneTitle: String
	let button: Button
	let onTapSignal: Signal<Void>
	private let onTapReadWriteSignal = ReadWriteSignal<Void>(())

	let pageAmountSignal: ReadWriteSignal<Int> = ReadWriteSignal(0)
	let onScrolledToPageIndexSignal = ReadWriteSignal<Int>(0)

	init(
		buttonContinueTitle: String,
		buttonDoneTitle: String,
		button: Button
	) {
		self.buttonContinueTitle = buttonContinueTitle
		self.buttonDoneTitle = buttonDoneTitle
		self.button = button
		onTapSignal = onTapReadWriteSignal.plain()
	}
}

extension PagerProceedButton: Viewable {
	func materialize(events: ViewableEvents) -> (UIButton, Disposable) {
		let bag = DisposeBag()
		let (buttonView, disposable) = button.materialize(events: events)
		buttonView.alpha = 0

		let buttonTitleSignal = ReadWriteSignal<String>("")

		func setButtonStyle(isMorePages _: Bool) {
			button.type.value = ButtonType.standard(
				backgroundColor: .brand(.secondaryButtonBackgroundColor),
				textColor: .brand(.secondaryButtonTextColor)
			)
		}

		func setButtonTitle(amount: Int, isMorePages: Bool) {
			guard amount != 0 else {
				buttonTitleSignal.value = ""
				return
			}
			buttonTitleSignal.value = isMorePages ? buttonContinueTitle : buttonDoneTitle
		}

		bag += button.onTapSignal.bindTo(onTapReadWriteSignal)

		bag += buttonTitleSignal.distinct().delay(by: 0.25)
			.transition(
				style: .crossDissolve(duration: 0.25),
				with: buttonView,
				animations: { title in self.button.title.value = title }
			)

		bag += pageAmountSignal.onValue { pageAmount in let isMorePages = pageAmount > 1

			setButtonTitle(amount: pageAmount, isMorePages: isMorePages)
			setButtonStyle(isMorePages: isMorePages)

			buttonView.alpha = 1
		}

		bag += onScrolledToPageIndexSignal.withLatestFrom(pageAmountSignal)
			.onValue { pageIndex, pageAmount in let isMorePages = pageIndex < (pageAmount - 1)

				setButtonTitle(amount: pageAmount, isMorePages: isMorePages)
				setButtonStyle(isMorePages: isMorePages)
			}

		return (
			buttonView,
			Disposer {
				disposable.dispose()
				bag.dispose()
			}
		)
	}
}
