import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct BankDetailsSection {
	@Inject var client: ApolloClient
	let urlScheme: String
}

extension BankDetailsSection: Viewable {
	func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
		let bag = DisposeBag()

		let section = SectionView(header: L10n.myPaymentBankRowLabel, footer: nil)
		let row = KeyValueRow()
		row.valueStyleSignal.value = .brand(.headline(color: .quartenary))

		bag += section.append(row)

		let dataSignal = client.watch(query: GraphQL.MyPaymentQuery())
		let noBankAccountSignal = dataSignal.filter { $0.bankAccount == nil }

		bag += noBankAccountSignal.map { _ in L10n.myPaymentNotConnected }.bindTo(row.keySignal)

		bag += dataSignal.compactMap { $0.bankAccount?.bankName }.bindTo(row.keySignal)

		bag += dataSignal.compactMap { $0.bankAccount?.descriptor }.bindTo(row.valueSignal)

		let myPaymentQuerySignal = client.watch(
			query: GraphQL.MyPaymentQuery(),
			cachePolicy: .returnCacheDataAndFetch
		)

		func addConnectPayment(_ data: GraphQL.MyPaymentQuery.Data) -> Disposable {
			let bag = DisposeBag()
			let hasAlreadyConnected = data.payinMethodStatus != .needsSetup
			let buttonText =
				hasAlreadyConnected
				? L10n.myPaymentDirectDebitReplaceButton : L10n.myPaymentDirectDebitButton

			let paymentSetupRow = RowView(title: buttonText, style: .brand(.headline(color: .link)))

			let setupImageView = UIImageView()
			setupImageView.image =
				hasAlreadyConnected ? hCoreUIAssets.editIcon.image : hCoreUIAssets.circularPlus.image
			setupImageView.tintColor = .brand(.link)

			paymentSetupRow.append(setupImageView)

			bag += section.append(paymentSetupRow).compactMap { section.viewController }
				.onValue { viewController in
					let setup = PaymentSetup(
						setupType: hasAlreadyConnected ? .replacement : .initial,
						urlScheme: self.urlScheme
					)
					viewController.present(
						setup,
						style: .modally(),
						options: [.defaults, .allowSwipeDismissAlways]
					)
				}

			bag += { section.remove(paymentSetupRow) }

			return bag
		}

		bag += myPaymentQuerySignal.onValueDisposePrevious { data in let innerBag = bag.innerBag()

			switch data.payinMethodStatus {
			case .pending:
				let pendingRow = RowView()

				innerBag += pendingRow.append(
					MultilineLabel(
						value: L10n.myPaymentUpdatingMessage,
						style: .brand(.footnote(color: .tertiary))
					)
				)

				section.append(pendingRow)

				innerBag += { section.remove(pendingRow) }

				innerBag += addConnectPayment(data)
			case .active, .needsSetup, .__unknown: innerBag += addConnectPayment(data)
			}

			return innerBag
		}

		return (section, bag)
	}
}
