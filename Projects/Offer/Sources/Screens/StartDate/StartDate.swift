import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct StartDate {
	let quoteBundle: GraphQL.QuoteBundleQuery.Data.QuoteBundle
	@Inject var state: OfferState
}

extension StartDate: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let viewController = UIViewController()
		viewController.title = L10n.offerSetStartDate
		viewController.preferredPresentationStyle = .detented(.large)
		let bag = DisposeBag()

		let scrollView = FormScrollView()

		let form = FormView()
		bag += viewController.install(form, scrollView: scrollView)

		var selectedDatesMap: [String: Date?] = [:]

		if let concurrentInception = quoteBundle.inception.asConcurrentInception {
			bag +=
				form.append(
					SingleStartDateSection(
						title: nil,
						switchingActivated: concurrentInception.currentInsurer?.switchable
							?? false,
						isCollapsible: false,
						initialStartDate: concurrentInception.startDate?.localDateToDate
					)
				)
				.onValue { date in
					concurrentInception.correspondingQuotes.forEach { quote in
						guard let quoteId = quote.asCompleteQuote?.id else {
							return
						}
						selectedDatesMap[quoteId] = date
					}
				}
		} else if let independentInceptions = quoteBundle.inception.asIndependentInceptions {
			bag += independentInceptions.inceptions.map { inception in
				form.append(
					SingleStartDateSection(
						title: quoteBundle.quoteFor(
							id: inception.correspondingQuote.asCompleteQuote?.id
						)?
						.displayName,
						switchingActivated: inception.currentInsurer?.switchable ?? false,
						isCollapsible: independentInceptions.inceptions.count > 1,
						initialStartDate: inception.startDate?.localDateToDate
					)
				)
				.onValue { date in
					guard let quoteId = inception.correspondingQuote.asCompleteQuote?.id else {
						return
					}
					selectedDatesMap[quoteId] = date
				}
			}
		}

		let buttonContainer = UIStackView()
		buttonContainer.axis = .vertical
		buttonContainer.spacing = 15
		buttonContainer.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 15)
		buttonContainer.isLayoutMarginsRelativeArrangement = true
		buttonContainer.insetsLayoutMarginsFromSafeArea = false

		let saveButton = Button(
            title: L10n.generalSaveButton,
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
					.onError { _ in
						viewController.present(
							Alert<Void>(
                                title: L10n.offerSaveStartDateErrorAlertTitle,
								message: L10n.offerSaveStartDateErrorAlertMessage,
								actions: [.init(title: L10n.alertOk, action: { () })]
							)
						)
						.onValue { _ in
							loadableSaveButton.isLoadingSignal.value = false
						}
					}
				}

				return bag
			}
		)
	}
}
