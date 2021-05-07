import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct KeyGearAddValuation {
	let id: String
	let category: GraphQL.KeyGearItemCategory
	let state = State()
	@Inject var client: ApolloClient

	struct State {
		let purchasePriceSignal = ReadWriteSignal<Int>(0)
		let purchaseDateSignal = ReadWriteSignal(Date())
	}
}

struct PurchasePrice: Viewable {
	let id: String
	let category: GraphQL.KeyGearItemCategory
	@Inject var client: ApolloClient

	func materialize(events _: ViewableEvents) -> (SectionView, Signal<Int>) {
		let bag = DisposeBag()

		let footerView = MultilineLabel(
			value: L10n.keyGearNotCovered(category.name.localizedLowercase),
			style: .brand(.footnote(color: .primary))
		)

		let footerViewContainer = UIStackView()
		footerViewContainer.isHidden = false
		footerViewContainer.axis = .vertical
		bag += footerViewContainer.addArranged(footerView)

		let section = SectionView(headerView: nil, footerView: footerViewContainer)

		let row = RowView()
		section.append(row)

		row.prepend(
			UILabel(value: L10n.keyGearAddPurchasePriceCellTitle, style: .brand(.headline(color: .primary)))
		)

		let textField = UITextField(value: "", placeholder: "0", style: .defaultRight)
		textField.keyboardType = .numeric

		bag += textField.addDoneToolbar()

		let amountSignal = client.watch(query: GraphQL.KeyGearItemQuery(id: id)).compactMap {
			$0.keyGearItem?.maxInsurableAmount?.fragments.monetaryAmountFragment.amount
		}.readable(initial: "0")

		bag += combineLatest(textField, amountSignal).animated(style: SpringAnimationStyle.lightBounce()) {
			value,
			amount in
			if let amount = Float(amount), let value = Float(value), value > amount {
				footerViewContainer.animationSafeIsHidden = false
			} else {
				footerViewContainer.animationSafeIsHidden = true
			}
			footerViewContainer.layoutIfNeeded()
			section.layoutIfNeeded()
		}

		row.append(textField)

		return (section, textField.providedSignal.hold(bag).compactMap { Int($0) })
	}
}

struct DatePicker: Viewable {
	func materialize(events: SelectableViewableEvents) -> (RowView, ReadWriteSignal<Date>) {
		let bag = DisposeBag()
		let row = RowView()

		let containerView = UIStackView()
		containerView.axis = .vertical
		containerView.spacing = 10
		row.append(containerView)

		let mainRowContainerView = UIStackView()
		mainRowContainerView.axis = .horizontal
		containerView.addArrangedSubview(mainRowContainerView)

		mainRowContainerView.addArrangedSubview(
			UILabel(value: L10n.keyGearYearmonthPickerTitle, style: .brand(.headline(color: .primary)))
		)

		let value = UILabel(
			value: Date().localDateString ?? "",
			style: TextStyle.brand(.headline(color: .link)).rightAligned
		)
		mainRowContainerView.addArrangedSubview(value)

		let picker = UIDatePicker()
		picker.maximumDate = Date()
		picker.calendar = Calendar.current
		picker.datePickerMode = .date
		picker.isHidden = true
		containerView.addArrangedSubview(picker)

		picker.snp.makeConstraints { make in make.height.equalTo(216) }

		bag += picker.onValue { date in value.value = date.localDateString ?? "" }

		bag += events.onSelect.animated(
			style: SpringAnimationStyle.lightBounce(),
			animations: { _ in picker.isHidden = !picker.isHidden
				picker.layoutSuperviewsIfNeeded()
				picker.layoutIfNeeded()
				picker.alpha = picker.isHidden ? 0 : 1
			}
		)

		return (row, picker.providedSignal.hold(bag))
	}
}

extension KeyGearAddValuation: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let bag = DisposeBag()
		let viewController = UIViewController()
		viewController.title = L10n.keyGearAddPurchaseInfoPageTitle
		let form = FormView()

		bag += viewController.install(form)

		let descriptionLabel = MultilineLabel(
			value: L10n.keyGearAddPurchaseInfoBody(category.name.localizedLowercase),
			style: TextStyle.brand(.body(color: .primary)).centerAligned
		)
		bag += form.append(descriptionLabel)

		bag += form.append(Spacing(height: 40))

		bag += form.append(PurchasePrice(id: id, category: category)).bindTo(state.purchasePriceSignal)

		bag += form.append(Spacing(height: 20))

		let dateSection = form.appendSection()

		bag += dateSection.append(DatePicker()).bindTo(state.purchaseDateSignal)

		bag += form.append(Spacing(height: 40))

		let button = LoadableButton(
			button: Button(
				title: L10n.keyGearItemViewAddPurchaseDateButton,
				type: .standard(
					backgroundColor: .brand(.primaryButtonBackgroundColor),
					textColor: .brand(.primaryButtonTextColor)
				)
			)
		)

		bag += form.append(button.wrappedIn(UIStackView()).wrappedIn(UIStackView())) { stackView in
			stackView.axis = .vertical
			stackView.alignment = .center
		}

		return (
			viewController,
			Future { completion in
				bag += button.onTapSignal.onValue { _ in button.isLoadingSignal.value = true

					self.client.perform(
						mutation: GraphQL.UpdateKeyGearValuationMutation(
							itemId: self.id,
							purchasePrice: GraphQL.MonetaryAmountV2Input(
								amount: self.state.purchasePriceSignal.value
									.description,
								currency: "SEK"
							),
							purchaseDate:
								self.state.purchaseDateSignal.value.localDateString
								?? ""
						)
					).onValue { _ in
						viewController.present(
							KeyGearValuation(itemId: self.id),
							options: [.defaults]
						).onValue { _ in completion(.success) }
					}
				}

				return DelayedDisposer(bag, delay: 2.0)
			}
		)
	}
}
