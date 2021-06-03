import Apollo
import Flow
import Form
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct Offer { @Inject var client: ApolloClient }

extension Offer {
	func startSignProcess(_ viewController: UIViewController) {
		viewController.present(
			BankIdSign().wrappedInCloseButton(),
			style: .detented(.medium, .large),
			options: [.defaults]
		)
		.onValue { _ in viewController.present(PostOnboarding(), style: .detented(.large)) }
	}

	static var primaryAccentColor: UIColor { .brand(.primaryBackground()) }
}

extension GraphQL.OfferQuery {
	convenience init() { self.init(locale: Localization.Locale.currentLocale.asGraphQLLocale()) }
}

extension Offer: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		let viewController = UIViewController()
		viewController.title = L10n.offerTitle
		viewController.navigationItem.hidesBackButton = true
		ApplicationState.preserveState(.offer)

		let bag = DisposeBag()

		let chatButton = UIBarButtonItem()
		chatButton.image = Asset.chat.image
		chatButton.tintColor = .brand(.primaryText())

		bag += chatButton.onValue { _ in
			bag +=
				viewController.present(OfferChat().wrappedInCloseButton(), style: .detented(.large))
				.disposable
		}

		viewController.navigationItem.rightBarButtonItem = chatButton

		let scrollView = FormScrollView()
		let form = FormView()
		bag += viewController.install(form, scrollView: scrollView)

		form.appendSpacing(.top)

		let stackView = UIStackView()
		stackView.axis = .vertical

		let offerSignal = client.watch(query: GraphQL.OfferQuery())

		let insuranceSignal = offerSignal.compactMap { $0.insurance }

		let offerHeader = OfferHeader(containerScrollView: scrollView, presentingViewController: viewController)

		bag += offerHeader.onSignTapSignal.onValue { _ in self.startSignProcess(viewController) }

		bag += stackView.addArranged(offerHeader.wrappedIn(UIStackView())) { stackView in
			stackView.layoutMargins = UIEdgeInsets(horizontalInset: 25, verticalInset: 35)
			stackView.isLayoutMarginsRelativeArrangement = true
		}

		bag += stackView.addArranged(Spacing(height: 16))

		bag += stackView.addArranged(Spacing(height: Float(UIScreen.main.bounds.height))) { spacingView in
			bag += Signal(after: 1.25)
				.animated(style: SpringAnimationStyle.mediumBounce()) { _ in
					spacingView.animationSafeIsHidden = true
				}
		}

		bag += stackView.addArranged(OfferSummary())

		bag += stackView.addArranged(OfferCoverage())

		let insuredAtOtherCompanySignal = insuranceSignal.map { $0.previousInsurer != nil }
			.readable(initial: false)

		bag += stackView.addArranged(
			OfferCoverageTerms(insuredAtOtherCompanySignal: insuredAtOtherCompanySignal)
		)

		let coverageSwitcher = WhenEnabled(insuredAtOtherCompanySignal, { OfferCoverageSwitcher() }) { _ in }

		bag += stackView.addArranged(coverageSwitcher)

		form.append(stackView)

		let offerSignButton = OfferSignButton(scrollView: scrollView)

		bag += offerSignButton.onTapSignal.onValue { _ in self.startSignProcess(viewController) }

		bag += scrollView.add(offerSignButton) { buttonView in
			buttonView.snp.makeConstraints { make in
				make.bottom.equalTo(scrollView.frameLayoutGuide.snp.bottom)
				make.trailing.leading.equalToSuperview()
			}

			let spacerView = UIView()
			stackView.addArrangedSubview(spacerView)

			spacerView.snp.makeConstraints { make in make.height.equalTo(buttonView.snp.height) }

			bag += spacerView.didLayoutSignal.onValue { _ in
				scrollView.scrollIndicatorInsets = UIEdgeInsets(
					top: 0,
					left: 0,
					bottom: spacerView.frame.height - buttonView.safeAreaInsets.bottom,
					right: 0
				)
			}

			buttonView.transform = CGAffineTransform(translationX: 0, y: 200)

			bag += scrollView.contentOffsetSignal.animated(style: SpringAnimationStyle.lightBounce()) {
				contentOffset in
				if contentOffset.y > 400 {
					buttonView.transform = CGAffineTransform.identity
				} else {
					buttonView.transform = CGAffineTransform(
						translationX: 0,
						y: buttonView.frame.height + form.safeAreaInsets.bottom + 20
					)
				}
			}
		}

		return (viewController, bag)
	}
}
