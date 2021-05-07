import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct ChangeCode {
	let service: ForeverService

	enum ResultError: Error { case cancelled }
}

extension ChangeCode: Presentable {
	func makeClearButton(_ row: RowView) -> UIControl {
		let clearButton = UIControl()
		clearButton.backgroundColor = .brand(.primaryBackground())
		clearButton.layer.cornerRadius = 12
		row.viewRepresentation.addSubview(clearButton)

		let clearButtonImageView = UIImageView()
		clearButtonImageView.contentMode = .scaleAspectFit
		clearButton.addSubview(clearButtonImageView)

		clearButtonImageView.snp.makeConstraints { make in
			make.top.bottom.trailing.leading.equalToSuperview().inset(7.5)
		}

		clearButtonImageView.image = hCoreUIAssets.close.image

		clearButton.snp.makeConstraints { make in make.width.height.equalTo(24)
			make.centerY.equalToSuperview()
			make.trailing.equalToSuperview().inset(15)
		}

		return clearButton
	}

	func materialize() -> (UIViewController, Future<Void>) {
		let viewController = UIViewController()
		let bag = DisposeBag()

		let cancelBarButtonItem = UIBarButtonItem(
			title: L10n.NavBar.cancel,
			style: .brand(.body(color: .primary))
		)
		viewController.navigationItem.leftBarButtonItem = cancelBarButtonItem

		let saveBarButtonItem = UIBarButtonItem(title: L10n.NavBar.save, style: .brand(.body(color: .link)))
		viewController.navigationItem.rightBarButtonItem = saveBarButtonItem

		let form = FormView()
		bag += viewController.install(form)

		form.appendSpacing(.top)
		form.append(L10n.ReferralsChangeCodeSheet.headline)
		form.appendSpacing(.inbetween)
		bag += form.append(
			MultilineLabel(
				value: L10n.ReferralsChangeCodeSheet.body,
				style: TextStyle.brand(.body(color: .tertiary)).centerAligned
			)
		)
		form.appendSpacing(.top)

		let textFieldSection = form.appendSection(
			header: nil,
			footer: nil,
			style: .brandGrouped(separatorType: .none, borderColor: .brand(.primaryButtonBackgroundColor))
		)
		let textFieldRow = textFieldSection.appendRow()

		let normalFieldStyle = FieldStyle.default.restyled { (style: inout FieldStyle) in
			style.text.alignment = .center
			style.autocorrection = .no
			style.autocapitalization = .none
		}

		let textField = UITextField(
			value: "",
			placeholder: L10n.ReferralsChangeCodeSheet.textFieldPlaceholder,
			style: normalFieldStyle
		)
		textFieldRow.append(textField)

		let clearButton = makeClearButton(textFieldRow.row)

		bag += clearButton.signal(for: .touchUpInside).atValue { textField.value = "" }.animated(
			style: .easeOut(duration: 0.25)
		) { clearButton.alpha = 0 }

		bag += service.dataSignal.atOnce().compactMap { $0?.discountCode }.take(first: 1).bindTo(
			textField,
			\.value
		)

		textField.becomeFirstResponder()

		let textFieldErrorSignal: ReadWriteSignal<ForeverChangeCodeError?> = ReadWriteSignal(nil).distinct()

		bag += textField.atValue { _ in textFieldErrorSignal.value = nil }.animated(
			style: .easeOut(duration: 0.25)
		) { value in clearButton.alpha = value.isEmpty ? 0 : 1 }

		let errorMessageLabel = MultilineLabel(
			value: "",
			style: TextStyle.brand(.footnote(color: .destructive)).centerAligned
		)

		bag += textFieldErrorSignal.compactMap { $0?.localizedDescription }.bindTo(errorMessageLabel.$value)

		form.appendSpacing(.inbetween)
		bag += form.append(errorMessageLabel) { errorMessageLabelView in
			func alphaAnimation(_ error: Error?) { errorMessageLabelView.alpha = error == nil ? 0 : 1 }

			func isHiddenAnimation(_ error: Error?) {
				errorMessageLabelView.animationSafeIsHidden = error == nil
			}

			bag += textFieldErrorSignal.atOnce().animated(style: .easeOut(duration: 0.15)) { error in
				if error == nil { alphaAnimation(error) } else { isHiddenAnimation(error) }
			}.animated(style: .easeOut(duration: 0.15)) { error in
				if error == nil { isHiddenAnimation(error) } else { alphaAnimation(error) }
			}.onValue { _ in
				viewController.navigationItem.setRightBarButton(saveBarButtonItem, animated: true)
			}
		}

		func onSave() -> Signal<Void> {
			let activityIndicator = UIActivityIndicatorView()
			activityIndicator.startAnimating()
			viewController.navigationItem.setRightBarButton(
				UIBarButtonItem(customView: activityIndicator),
				animated: true
			)

			return service.changeDiscountCode(textField.value).delay(by: 0.25).atValue { result in
				if let error = result.right { textFieldErrorSignal.value = error }
			}.filter(predicate: { $0.left != nil }).toVoid()
		}

		return (
			viewController,
			Future { completion in
				bag += cancelBarButtonItem.onValue { completion(.failure(ResultError.cancelled)) }

				bag += textField.shouldReturn.set { _ -> Bool in
					bag += onSave().onValue { completion(.success) }
					return true
				}

				bag += saveBarButtonItem.onValue { bag += onSave().onValue { completion(.success) } }

				return DelayedDisposer(bag, delay: 2)
			}
		)
	}
}
