import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct StartDate {
	@Inject var state: OfferState
}

extension StartDate: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let viewController = UIViewController()
		viewController.title = L10n.offerSetStartDate
		let bag = DisposeBag()

		let scrollView = FormScrollView()

		let form = FormView()
		bag += viewController.install(form, scrollView: scrollView)

		var selectedDatesMap: [String: Date?] = [:]

		bag += state.quotesSignal.onValueDisposePrevious { quotes in
			let bag = DisposeBag()

			bag += quotes.map { quote in
				form.append(
					SingleStartDateSection(
						title: quote.displayName,
						switchingActivated: quote.currentInsurer?.switchable ?? false,
						isCollapsible: quotes.count > 1
					)
				)
				.onValue { date in
					selectedDatesMap[quote.id] = date
				}
			}

			return bag
		}

		let buttonContainer = UIStackView()
		buttonContainer.axis = .vertical
		buttonContainer.spacing = 15
		buttonContainer.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 15)
		buttonContainer.isLayoutMarginsRelativeArrangement = true
		buttonContainer.insetsLayoutMarginsFromSafeArea = false

		let saveButton = Button(
			title: "Save",
			type: .standard(
				backgroundColor: .brand(.secondaryButtonBackgroundColor),
				textColor: .brand(.secondaryButtonTextColor)
			)
		)
		let loadableSaveButton = LoadableButton(button: saveButton)

		bag += buttonContainer.addArranged(loadableSaveButton)

		bag += buttonContainer.didLayoutSignal.onValue { _ in
			buttonContainer.layoutMargins = UIEdgeInsets(
				top: 0,
				left: 15,
				bottom: scrollView.safeAreaInsets.bottom == 0 ? 15 : scrollView.safeAreaInsets.bottom,
				right: 15
			)

			let size = buttonContainer.systemLayoutSizeFitting(.zero)
			scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: size.height, right: 0)
			scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: size.height, right: 0)
		}

		scrollView.addSubview(buttonContainer)

		buttonContainer.snp.makeConstraints { make in
			make.bottom.equalTo(scrollView.frameLayoutGuide.snp.bottom)
			make.trailing.leading.equalToSuperview()
		}

		return (
			viewController,
			Future { completion in
				bag += loadableSaveButton.onTapSignal.onValue { _ in
					loadableSaveButton.isLoadingSignal.value = true

					join(
						selectedDatesMap.map { quoteId, date in
							state.updateStartDate(quoteId: quoteId, date: date).toVoid()
						}
					)
					.onValue { _ in
						loadableSaveButton.isLoadingSignal.value = false
						completion(.success)
					}
				}

				return bag
			}
		)
	}
}
