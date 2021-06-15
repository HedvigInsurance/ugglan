import Apollo
import Flow
import Form
import Foundation
import Offer
import OfferTesting
import Presentation
import TestingUtil
import UIKit
import hCore
import hGraphQL

struct Debug {}

extension Debug: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		let viewController = UIViewController()
		viewController.title = "Offer Example"

		let bag = DisposeBag()

		let form = FormView()

		let section = form.appendSection(headerView: UILabel(value: "Offer", style: .default), footerView: nil)
		let presentFullScreenRow = section.appendRow(title: "Present in full screen")
		let presentFullScreenSwitch = UISwitch()
		presentFullScreenRow.append(presentFullScreenSwitch)
		let presentWithLargeTitlesRow = section.appendRow(title: "Present with large titles")
		let presentWithLargeTitleSwitch = UISwitch()
		presentWithLargeTitlesRow.append(presentWithLargeTitleSwitch)

		func presentOffer(_ mockInterceptorProvider: MockInterceptorProvider) {
			mockInterceptorProvider.handle(GraphQL.ChangeStartDateMutation.self) { operation in
				.success(
					GraphQL.ChangeStartDateMutation.Data(
						editQuote: .makeCompleteQuote(startDate: operation.startDate)
					)
				)
			}

			ApolloClient.createMock(mockInterceptorProvider: mockInterceptorProvider)

			viewController.present(
				Offer(offerIDContainer: .stored, menu: Menu(title: nil, children: [])).withCloseButton,
				style: presentFullScreenSwitch.isOn
					? .modally(
						presentationStyle: .fullScreen,
						transitionStyle: nil,
						capturesStatusBarAppearance: nil
					) : .detented(.large),
				options: presentWithLargeTitleSwitch.isOn
					? [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
					: [.defaults]
			)
		}

		bag += section.appendRow(title: "Swedish apartment")
			.onValue {
				let mockInterceptorProvider = MockInterceptorProvider()
				mockInterceptorProvider.handle(GraphQL.QuoteBundleQuery.self) { variables in
					.success(.makeSwedishApartment())
				}
				presentOffer(mockInterceptorProvider)
			}

		bag += section.appendRow(title: "Swedish house")
			.onValue {
				let mockInterceptorProvider = MockInterceptorProvider()
				mockInterceptorProvider.handle(GraphQL.QuoteBundleQuery.self) { variables in
					.success(
						.makeSwedishHouse(
							bundleCost: .init(
								monthlyGross: .init(amount: "100", currency: "SEK"),
								monthlyDiscount: .init(amount: "0", currency: "SEK"),
								monthlyNet: .init(amount: "100", currency: "SEK")
							),
							redeemedCampaigns: []
						)
					)
				}
				presentOffer(mockInterceptorProvider)
			}

		bag += section.appendRow(title: "Swedish house - discounted")
			.onValue {
				let mockInterceptorProvider = MockInterceptorProvider()
				mockInterceptorProvider.handle(GraphQL.QuoteBundleQuery.self) { variables in
					.success(
						.makeSwedishHouse(
							bundleCost: .init(
								monthlyGross: .init(amount: "110", currency: "SEK"),
								monthlyDiscount: .init(amount: "10", currency: "SEK"),
								monthlyNet: .init(amount: "100", currency: "SEK")
							),
							redeemedCampaigns: [.init(displayValue: "-10 kr per month")]
						)
					)
				}
				presentOffer(mockInterceptorProvider)
			}

		bag += section.appendRow(title: "Swedish house - discounted indefinite")
			.onValue {
				let mockInterceptorProvider = MockInterceptorProvider()
				mockInterceptorProvider.handle(GraphQL.QuoteBundleQuery.self) { variables in
					.success(
						.makeSwedishHouse(
							bundleCost: .init(
								monthlyGross: .init(amount: "110", currency: "SEK"),
								monthlyDiscount: .init(amount: "27.5", currency: "SEK"),
								monthlyNet: .init(amount: "82.5", currency: "SEK")
							),
							redeemedCampaigns: [.init(displayValue: "-25% forever")]
						)
					)
				}
				presentOffer(mockInterceptorProvider)
			}

		bag += section.appendRow(title: "Swedish house - discounted free months")
			.onValue {
				let mockInterceptorProvider = MockInterceptorProvider()
				mockInterceptorProvider.handle(GraphQL.QuoteBundleQuery.self) { variables in
					.success(
						.makeSwedishHouse(
							bundleCost: .init(
								monthlyGross: .init(amount: "110", currency: "SEK"),
								monthlyDiscount: .init(amount: "110", currency: "SEK"),
								monthlyNet: .init(amount: "0", currency: "SEK")
							),
							redeemedCampaigns: [.init(displayValue: "3 free months")]
						)
					)
				}
				presentOffer(mockInterceptorProvider)
			}

		bag += section.appendRow(title: "Swedish house - discounted percentage for months")
			.onValue {
				let mockInterceptorProvider = MockInterceptorProvider()
				mockInterceptorProvider.handle(GraphQL.QuoteBundleQuery.self) { variables in
					.success(
						.makeSwedishHouse(
							bundleCost: .init(
								monthlyGross: .init(amount: "110", currency: "SEK"),
								monthlyDiscount: .init(amount: "27.5", currency: "SEK"),
								monthlyNet: .init(amount: "82.5", currency: "SEK")
							),
							redeemedCampaigns: [
								.init(displayValue: "25% discount for 3 months")
							]
						)
					)
				}
				presentOffer(mockInterceptorProvider)
			}

		bag += section.appendRow(title: "Norwegian bundle")
			.onValue {
				let mockInterceptorProvider = MockInterceptorProvider()
				mockInterceptorProvider.handle(GraphQL.QuoteBundleQuery.self) { variables in
					.success(.makeNorwegianBundle())
				}
				presentOffer(mockInterceptorProvider)
			}

		bag += viewController.install(form)

		return (viewController, bag)
	}
}
