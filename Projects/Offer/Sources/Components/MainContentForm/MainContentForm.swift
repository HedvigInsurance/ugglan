import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct MainContentForm {
	let scrollView: UIScrollView
	@Inject var state: OfferState
}

extension MainContentForm: Presentable {
	func materialize() -> (UIStackView, Disposable) {
		let bag = DisposeBag()
		let container = PassThroughStackView()
		container.axis = .vertical
		container.alignment = .leading
		container.allowTouchesOfViewsOutsideBounds = true

		let formContainer = UIStackView()
		formContainer.axis = .vertical
		formContainer.edgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
		formContainer.insetsLayoutMarginsFromSafeArea = true
		container.addArrangedSubview(formContainer)

		let form = FormView()
		form.dynamicStyle = DynamicFormStyle { _ in
			.init(insets: .zero)
		}
		form.layer.cornerRadius = .defaultCornerRadius
		form.layer.masksToBounds = true
		form.backgroundColor = .brand(.primaryBackground())
		formContainer.addArrangedSubview(form)

		bag += form.append(DetailsSection())

		form.appendSpacing(.inbetween)

		bag += form.append(CoverageSection())

		form.appendSpacing(.inbetween)

		bag += form.append(FrequentlyAskedQuestionsSection())

		bag += merge(
			scrollView.didLayoutSignal,
			container.didLayoutSignal,
			formContainer.didLayoutSignal,
			form.didLayoutSignal,
			scrollView.didScrollSignal,
			state.quotesSignal.toVoid()
		)
		.onValue {
			let bottomContentInset: CGFloat = scrollView.safeAreaInsets.bottom + 20

			if container.frame.width > Header.trailingAlignmentBreakpoint {
				formContainer.snp.remakeConstraints { make in
					make.width.equalTo(
						container.frame.width
							- (container.frame.width
								* Header.trailingAlignmentFormPercentageWidth)
					)
				}

				guard !state.isLoadingSignal.value else {
					return
				}

				let pointInScrollView = scrollView.convert(
					formContainer.frameWithoutTransform,
					from: container
				)
				let transformY = -(pointInScrollView.origin.y - Header.insetTop)

				formContainer.transform = CGAffineTransform(translationX: 0, y: transformY)
				scrollView.scrollIndicatorInsets = UIEdgeInsets(
					top: 0,
					left: 0,
					bottom: transformY + bottomContentInset,
					right: 0
				)
				scrollView.contentInset = UIEdgeInsets(
					top: 0,
					left: 0,
					bottom: transformY + bottomContentInset,
					right: 0
				)

				let extraInsetLeft: CGFloat = scrollView.safeAreaInsets.left > 0 ? 0 : 15

				formContainer.layoutMargins = UIEdgeInsets(
					top: 0,
					left: 15 + extraInsetLeft,
					bottom: 0,
					right: 15
				)
			} else {
				formContainer.snp.remakeConstraints { make in
					make.width.equalToSuperview()
				}
				formContainer.transform = CGAffineTransform.identity
				scrollView.scrollIndicatorInsets = .zero
				scrollView.contentInset = UIEdgeInsets(
					top: 0,
					left: 0,
					bottom: bottomContentInset,
					right: 0
				)
				formContainer.layoutMargins = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
			}

			scrollView.layoutIfNeeded()
		}

		return (container, bag)
	}
}
