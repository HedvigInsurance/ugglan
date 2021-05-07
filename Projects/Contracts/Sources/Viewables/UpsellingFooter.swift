import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct UpsellingFooter { @Inject var client: ApolloClient }

extension UpsellingFooter {
	struct UpsellingBox: Viewable {
		let title: String
		let description: String
		let buttonText: String

		func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
			let outerView = UIStackView()
			let stylingView = UIView()
			stylingView.layer.cornerRadius = 8
			stylingView.backgroundColor = .brand(.secondaryBackground())

			outerView.addArrangedSubview(stylingView)

			let stackView = UIStackView()
			stackView.axis = .vertical
			stackView.spacing = 10
			stackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 20)
			stackView.isLayoutMarginsRelativeArrangement = true
			stylingView.addSubview(stackView)

			stackView.snp.makeConstraints { make in make.top.bottom.leading.trailing.equalToSuperview() }

			let bag = DisposeBag()

			bag += stackView.addArranged(
				MultilineLabel(
					value: title,
					style: TextStyle.brand(.title3(color: .primary)).centerAligned
				)
			)
			bag += stackView.addArranged(
				MultilineLabel(
					value: description,
					style: TextStyle.brand(.body(color: .secondary)).centerAligned
				)
			) { view in stackView.setCustomSpacing(20, after: view) }

			let button = Button(
				title: buttonText,
				type: .outline(
					borderColor: .brand(.secondaryButtonBackgroundColor),
					textColor: .brand(.secondaryButtonBackgroundColor)
				)
			)

			bag += button.onTapSignal.compactMap { stackView.viewController }.onValue { viewController in
				Contracts.openFreeTextChatHandler(viewController)
			}

			bag += stackView.addArranged(button.wrappedIn(UIStackView())) { view in view.axis = .vertical
				view.alignment = .center
			}

			return (outerView, bag)
		}
	}
}

extension UpsellingFooter: Viewable {
	func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 15
		stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15)
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.alpha = 0
		stackView.transform = CGAffineTransform(translationX: 0, y: 100)
		let bag = DisposeBag()

		bag += client.watch(
			query: GraphQL.ContractsQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()),
			cachePolicy: .fetchIgnoringCacheData
		).compactMap { $0.contracts }.delay(by: 0.5).onValueDisposePrevious { contracts in
			let innerBag = DisposeBag()

			innerBag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
				stackView.alpha = 1
				stackView.transform = CGAffineTransform.identity
			}

			switch Localization.Locale.currentLocale.market {
			case .no:
				let hasTravelAgreement = contracts.contains(where: { contract -> Bool in
					contract.currentAgreement.asNorwegianTravelAgreement != nil
				})

				if !hasTravelAgreement {
					innerBag += stackView.addArranged(
						UpsellingBox(
							title: L10n.upsellNotificationTravelTitle,
							description: L10n.upsellNotificationTravelDescription,
							buttonText: L10n.upsellNotificationTravelCta
						)
					)
				}

				let hasHomeContentsAgreement = contracts.contains(where: { contract -> Bool in
					contract.currentAgreement.asNorwegianHomeContentAgreement != nil
				})

				if !hasHomeContentsAgreement {
					innerBag += stackView.addArranged(
						UpsellingBox(
							title: L10n.upsellNotificationContentTitle,
							description: L10n.upsellNotificationContentDescription,
							buttonText: L10n.upsellNotificationContentCta
						)
					)
				}
			default: break
			}

			return innerBag
		}

		return (stackView, bag)
	}
}
