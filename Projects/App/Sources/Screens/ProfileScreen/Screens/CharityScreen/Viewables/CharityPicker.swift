import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hGraphQL

struct CharityPicker {
	@Inject var client: ApolloClient
	let presentingViewController: UIViewController

	init(presentingViewController: UIViewController) { self.presentingViewController = presentingViewController }
}

extension CharityPicker: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Signal<CharityOption>) {
		let bag = DisposeBag()
		let table = Table<EmptySection, CharityOption>(rows: [])

		let sectionStyle = SectionStyle(
			rowInsets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0),
			itemSpacing: 0,
			minRowHeight: 10,
			background: .none,
			selectedBackground: .none,
			header: .none,
			footer: .none
		)

		let dynamicSectionStyle = DynamicSectionStyle { _ in sectionStyle }

		let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)

		let tableKit = TableKit<EmptySection, CharityOption>(
			table: table,
			style: style,
			holdIn: bag,
			headerForSection: { _, _ in let headerStackView = UIStackView()
				headerStackView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 10)
				headerStackView.isLayoutMarginsRelativeArrangement = true

				let label = UILabel(
					value: L10n.charityOptionsHeaderTitle,
					style: .brand(.headline(color: .primary))
				)

				headerStackView.addArrangedSubview(label)

				return headerStackView
			},
			footerForSection: { _, _ in let footerStackView = UIStackView()
				footerStackView.edgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 30)
				footerStackView.isLayoutMarginsRelativeArrangement = true

				let charityInformationButton = CharityInformationButton(
					presentingViewController: self.presentingViewController
				)
				bag += footerStackView.addArranged(charityInformationButton)

				return footerStackView
			}
		)

		let charityHeader = CharityHeader()
		bag += tableKit.view.addTableHeaderView(charityHeader)

		bag += tableKit.delegate.willDisplayCell.onValue { cell, indexPath in
			cell.layer.zPosition = CGFloat(indexPath.row)
		}

		let rows = ReadWriteSignal<[CharityOption]>([])

		bag += rows.atOnce().onValue { charityOptions in
			tableKit.set(Table(rows: charityOptions), animation: .none, rowIdentifier: { $0.title })
		}

		bag += client.watch(query: GraphQL.CharityOptionsQuery()).compactMap {
			$0.cashbackOptions.compactMap { $0 }
		}.onValue { cashbackOptions in
			let charityOptions = cashbackOptions.map { cashbackOption in
				CharityOption(
					id: cashbackOption.id ?? "",
					name: cashbackOption.name ?? "",
					title: cashbackOption.title ?? "",
					description: cashbackOption.description ?? "",
					paragraph: cashbackOption.paragraph ?? ""
				)
			}

			rows.value = charityOptions
		}

		return (
			tableKit.view,
			Signal { callback in
				bag += rows.atOnce().onValueDisposePrevious { charityOptions -> Disposable? in
					let innerBag = bag.innerBag()

					innerBag += charityOptions.map { charityOption -> Disposable in
						charityOption.onSelectSignal.onValueDisposePrevious { buttonView in
							let dismissCallbacker = Callbacker<Void>()

							let bubbleLoading = BubbleLoading(
								originatingView: buttonView,
								dismissSignal: dismissCallbacker.signal()
							)

							self.presentingViewController.present(
								bubbleLoading,
								style: .modally(
									presentationStyle: .overFullScreen,
									transitionStyle: .none,
									capturesStatusBarAppearance: true
								),
								options: [.unanimated]
							)

							bag += bubbleLoading.dismissSignal.delay(by: 0.2).onValue { _ in
								callback(charityOption)
							}

							return self.client.perform(
								mutation: GraphQL.SelectCharityMutation(
									id: charityOption.id
								)
							).onValue { _ in dismissCallbacker.callAll() }.disposable
						}
					}

					return innerBag
				}

				return bag
			}
		)
	}
}
