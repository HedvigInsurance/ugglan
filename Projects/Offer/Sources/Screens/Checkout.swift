import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct Checkout {
	@Inject var state: OfferState
}

class AccessoryBaseView: UIView {
	override var intrinsicContentSize: CGSize { CGSize(width: 0, height: 0) }

	init() {
		super.init(frame: .zero)
		autoresizingMask = .flexibleHeight
	}

	required init?(
		coder: NSCoder
	) {
		fatalError("init(coder:) has not been implemented")
	}
}

class AccessoryViewController<Accessory: Presentable>: UIViewController
where Accessory.Matter: UIView, Accessory.Result == Disposable {
	let accessoryView: Accessory.Matter

	init(
		accessoryView: Accessory
	) {
		let (view, disposable) = accessoryView.materialize()
		self.accessoryView = view

		let bag = DisposeBag()

		bag += disposable

		super.init(nibName: nil, bundle: nil)

		bag += deallocSignal.onValue { _ in bag.dispose() }
	}

	@available(*, unavailable) required init?(
		coder _: NSCoder
	) { fatalError("init(coder:) has not been implemented") }

	override var canBecomeFirstResponder: Bool { true }

	override var inputAccessoryView: UIView? { accessoryView }

	override var disablesAutomaticKeyboardDismissal: Bool { true }
}

struct CheckoutButton: Presentable {
	@ReadWriteState var isEnabled: Bool = false
	@ReadWriteState var isLoading: Bool = false

	func materialize() -> (UIView, Disposable) {
		let view = AccessoryBaseView()
		let bag = DisposeBag()

		let safeAreaWrapperView = UIView()
		view.addSubview(safeAreaWrapperView)

		safeAreaWrapperView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		let baseLayoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 15)

		let containerView = UIStackView()
		containerView.isLayoutMarginsRelativeArrangement = true
		containerView.insetsLayoutMarginsFromSafeArea = true
		containerView.layoutMargins = baseLayoutMargins
		containerView.axis = .horizontal
		safeAreaWrapperView.addSubview(containerView)

		containerView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		let button = Button(
			title: L10n.offerSignButton,
			type: .standard(
				backgroundColor: .brand(.secondaryButtonBackgroundColor),
				textColor: .brand(.secondaryButtonTextColor)
			)
		)
		bag += $isEnabled.atOnce().bindTo(button.isEnabled)

		let loadableButton = LoadableButton(button: button)
		bag += $isLoading.atOnce().bindTo(loadableButton.isLoadingSignal)

		bag += containerView.addArranged(
			loadableButton
		)

		bag += view.keyboardSignal(priority: .contentInsets)
			.onValue({ keyboard in
				guard let viewController = view.viewController else {
					return
				}

				let frameWidth = view.frame.width
				let viewControllerWidth = viewController.view.frame.width
				let halfWidth = (frameWidth - viewControllerWidth) / 2

				containerView.layoutMargins =
					baseLayoutMargins
					+ UIEdgeInsets(
						top: 0,
						left: halfWidth,
						bottom: view.safeAreaInsets.bottom == 0 ? 0 : 20,
						right: halfWidth
					)
			})

		return (view, bag)
	}
}

extension Checkout: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let checkoutButton = CheckoutButton()
		let viewController = AccessoryViewController(accessoryView: checkoutButton)
		viewController.title = L10n.checkoutTitle
		let bag = DisposeBag()

		let form = FormView()
		bag += viewController.install(form)

		bag += state.dataSignal.compactMap { $0.quoteBundle }
			.onFirstValue({ quoteBundle in
				let header = UIStackView()
				header.spacing = 16
				header.axis = .vertical

				let titleLabel = MultilineLabel(
					value: quoteBundle.quotes.reduce(
						"",
						{ previousString, quote in
							return previousString.isEmpty
								? quote.displayName
								: "\(previousString) + \n\(quote.displayName)"
						}
					),
					style: .brand(.title1(color: .secondary))
						.restyled({ (style: inout TextStyle) in
							style.lineHeight = quoteBundle.quotes.count > 1 ? 45 : 0
						})
				)
				bag += header.addArranged(titleLabel)

				bag += header.addArrangedSubview(PriceRow(placement: .checkout))

				let section = SectionView(headerView: header, footerView: nil)

				form.append(section)

				let emailRow = RowView(title: "Email", style: .brand(.title3(color: .primary)))
				emailRow.alignment = .leading
				emailRow.axis = .vertical
				emailRow.distribution = .fill
				section.append(emailRow)

				let emailMasking = Masking(type: .email)

				let emailTextField = UITextField(
					value: "",
					placeholder: L10n.emailRowTitle,
					style: .default
				)
				emailTextField.returnKeyType = .next
				emailMasking.applySettings(emailTextField)
				emailTextField.clearButtonMode = .whileEditing
				emailTextField.becomeFirstResponder()
				emailRow.append(emailTextField)

				bag += emailMasking.applyMasking(emailTextField)

				let ssnMasking = Localization.Locale.currentLocale.market.masking

				let ssnRow = RowView(
					title: "National Identity Number",
					style: .brand(.title3(color: .primary))
				)
				ssnRow.alignment = .leading
				ssnRow.axis = .vertical
				ssnRow.distribution = .fill
				section.append(ssnRow)

				let ssnTextField = UITextField(
					value: "",
					placeholder: L10n.SimpleSignLogin.TextField.helperText,
					style: .default
				)
				ssnMasking.applySettings(ssnTextField)
				ssnTextField.clearButtonMode = .whileEditing
				ssnRow.append(ssnTextField)

				bag += ssnMasking.applyMasking(ssnTextField)

				bag += form.chainAllControlResponders()

				let isValidSignal = combineLatest(
					ssnMasking.isValidSignal(ssnTextField),
					emailMasking.isValidSignal(emailTextField)
				)
				.map { ssnValid, emailValid in ssnValid && emailValid }

				bag += isValidSignal.filter { valid in valid }
					.onValue { _ in
						checkoutButton.$isLoading.value = true

						join(
							quoteBundle.quotes.map { quote in
								state.checkoutUpdate(
									quoteId: quote.id,
									email: emailMasking.unmaskedValue(
										text: emailTextField.value
									),
									ssn: ssnMasking.unmaskedValue(
										text: ssnTextField.value
									)
								)
							}
						)
						.onValue { _ in
							checkoutButton.$isLoading.value = false
						}
					}

				bag +=
					isValidSignal
					.bindTo(checkoutButton.$isEnabled)
			})

		return (
			viewController,
			Future { completion in

				return bag
			}
		)
	}
}

extension Localization.Locale.Market {
	fileprivate var masking: Masking {
		switch self {
		case .no: return .init(type: .norwegianPersonalNumber)
		case .se: return .init(type: .personalNumber)
		case .dk: return .init(type: .danishPersonalNumber)
		}
	}
}
