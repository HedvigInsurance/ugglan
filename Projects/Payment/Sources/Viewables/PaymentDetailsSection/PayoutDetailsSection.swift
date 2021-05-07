import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct PayoutDetailsSection {
	@Inject var client: ApolloClient
	let urlScheme: String
}

extension PayoutDetailsSection: Viewable {
	func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
		let bag = DisposeBag()

		let section = SectionView(header: L10n.PaymentScreen.payoutSectionTitle, footer: nil)
		section.isHidden = true

		let dataSignal = client.watch(
			query: GraphQL.ActivePayoutMethodsQuery(),
			cachePolicy: .returnCacheDataAndFetch
		)

		let payOutOptions = AdyenMethodsList.payOutOptions

		func presentPayOut(_ viewController: UIViewController) {
			payOutOptions.onValue { options in
				viewController.present(
					AdyenPayOut(adyenOptions: options, urlScheme: urlScheme).wrappedInCloseButton(),
					style: .detented(.scrollViewContentSize(20)),
					options: [.defaults, .allowSwipeDismissAlways]
				)
			}
		}

		bag += combineLatest(dataSignal, payOutOptions.valueSignal.plain()).onValueDisposePrevious {
			data,
			options in let bag = DisposeBag()
			let status = data.activePayoutMethods?.status

			if options.paymentMethods.regular.isEmpty {
				section.isHidden = true
				return bag
			}

			section.isHidden = false

			if status == .active {
				let valueRow = RowView()
				section.append(valueRow)

				let valueStackView = UIStackView()
				valueStackView.spacing = 10
				valueStackView.axis = .vertical

				valueRow.append(valueStackView)

				let valueHorizontalStackView = UIStackView()
				valueHorizontalStackView.spacing = 10
				valueHorizontalStackView.axis = .horizontal
				valueHorizontalStackView.distribution = .fillProportionally
				valueStackView.addArrangedSubview(valueHorizontalStackView)

				let valueImageView = UIImageView()
				valueImageView.image = hCoreUIAssets.circularCheckmark.image
				valueImageView.contentMode = .scaleAspectFit

				valueImageView.snp.makeConstraints { make in make.width.equalTo(22) }

				valueHorizontalStackView.addArrangedSubview(valueImageView)

				let valueLabel = UILabel(
					value: L10n.PaymentScreen.payConnectedLabel,
					style: .brand(.headline(color: .primary))
				)
				valueHorizontalStackView.addArrangedSubview(valueLabel)

				bag += valueStackView.addArranged(
					MultilineLabel(
						value: L10n.PaymentScreen.payOutConnectedPayoutFooterConnected,
						style: .brand(.footnote(color: .secondary))
					)
				)

				let connectRow = RowView(
					title: L10n.PaymentScreen.payOutChangePayoutButton,
					style: .brand(.headline(color: .link))
				)

				let connectImageView = UIImageView()
				connectImageView.image = hCoreUIAssets.editIcon.image
				connectImageView.tintColor = .brand(.link)

				connectRow.append(connectImageView)

				bag += section.append(connectRow).compactMap { connectRow.viewController }.onValue(
					presentPayOut
				)

				bag += {
					section.remove(valueRow)
					section.remove(connectRow)
				}
			} else if status == .pending {
				let valueRow = RowView()
				section.append(valueRow)

				let valueStackView = UIStackView()
				valueStackView.spacing = 10
				valueStackView.axis = .vertical

				valueRow.append(valueStackView)

				let valueLabel = UILabel(
					value: L10n.PaymentScreen.payOutProcessing,
					style: .brand(.headline(color: .primary))
				)
				valueStackView.addArrangedSubview(valueLabel)

				bag += valueStackView.addArranged(
					MultilineLabel(
						value: L10n.PaymentScreen.PayOut.footerPending,
						style: .brand(.footnote(color: .secondary))
					)
				)

				let connectRow = RowView(
					title: L10n.PaymentScreen.payOutChangePayoutButton,
					style: .brand(.headline(color: .link))
				)

				let connectImageView = UIImageView()
				connectImageView.image = hCoreUIAssets.editIcon.image
				connectImageView.tintColor = .brand(.link)

				connectRow.append(connectImageView)

				bag += section.append(connectRow).compactMap { connectRow.viewController }.onValue(
					presentPayOut
				)

				bag += {
					section.remove(valueRow)
					section.remove(connectRow)
				}
			} else {
				let connectRow = RowView(
					title: L10n.PaymentScreenConnect.payOutConnectPayoutButton,
					style: .brand(.headline(color: .link))
				)

				let connectImageView = UIImageView()
				connectImageView.image = hCoreUIAssets.circularPlus.image
				connectImageView.tintColor = .brand(.link)

				connectRow.append(connectImageView)

				bag += section.append(connectRow).compactMap { connectRow.viewController }.onValue(
					presentPayOut
				)

				let footerRow = RowView()
				bag += footerRow.append(
					MultilineLabel(
						value: L10n.PaymentScreen.payOutFooterNotConnected,
						style: .brand(.footnote(color: .secondary))
					)
				)

				section.append(footerRow)

				bag += {
					section.remove(connectRow)
					section.remove(footerRow)
				}
			}

			return bag
		}

		return (section, bag)
	}
}
