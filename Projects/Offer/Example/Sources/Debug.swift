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

		func presentOffer<Mock: GraphQLMock>(@GraphQLMockBuilder _ mocks: () -> Mock) {
			ApolloClient.createMock {
				mocks()
				sharedMocks
			}

			viewController.present(
				Offer(offerIDContainer: .stored, menu: Menu(title: nil, children: []))
					.wrappedInCloseButton(),
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
				presentOffer {
					QueryMock(GraphQL.QuoteBundleQuery.self) { _ in
						.makeSwedishApartment()
					}
				}
			}

		bag += section.appendRow(title: "Swedish house")
			.onValue {
				presentOffer {
					QueryMock(GraphQL.QuoteBundleQuery.self) { _ in
						.makeSwedishHouse(
							bundleCost: .init(
								monthlyGross: .init(amount: "100", currency: "SEK"),
								monthlyDiscount: .init(amount: "0", currency: "SEK"),
								monthlyNet: .init(amount: "100", currency: "SEK")
							),
							redeemedCampaigns: []
						)
					}

					MutationMock(GraphQL.SignQuotesMutation.self) { operation in
						.init(signQuotes: .makeSwedishBankIdSession(autoStartToken: "token"))
					}
				}
			}

		bag += section.appendRow(title: "Swedish house - discounted")
			.onValue {
				presentOffer {
					QueryMock(GraphQL.QuoteBundleQuery.self) { variables in
						.makeSwedishHouse(
							bundleCost: .init(
								monthlyGross: .init(amount: "110", currency: "SEK"),
								monthlyDiscount: .init(amount: "10", currency: "SEK"),
								monthlyNet: .init(amount: "100", currency: "SEK")
							),
							redeemedCampaigns: [.init(displayValue: "-10 kr per month")]
						)

					}
				}
			}

		bag += section.appendRow(title: "Swedish house - discounted indefinite")
			.onValue {
				presentOffer {
					QueryMock(GraphQL.QuoteBundleQuery.self) { variables in
						.makeSwedishHouse(
							bundleCost: .init(
								monthlyGross: .init(amount: "110", currency: "SEK"),
								monthlyDiscount: .init(amount: "27.5", currency: "SEK"),
								monthlyNet: .init(amount: "82.5", currency: "SEK")
							),
							redeemedCampaigns: [.init(displayValue: "-25% forever")]
						)

					}
				}
			}

		bag += section.appendRow(title: "Swedish house - discounted free months")
			.onValue {
				presentOffer {
					QueryMock(GraphQL.QuoteBundleQuery.self) { variables in
						.makeSwedishHouse(
							bundleCost: .init(
								monthlyGross: .init(amount: "110", currency: "SEK"),
								monthlyDiscount: .init(amount: "110", currency: "SEK"),
								monthlyNet: .init(amount: "0", currency: "SEK")
							),
							redeemedCampaigns: [.init(displayValue: "3 free months")]
						)

					}
				}
			}

		bag += section.appendRow(title: "Swedish house - discounted percentage for months")
			.onValue {
				presentOffer {
					QueryMock(GraphQL.QuoteBundleQuery.self) { variables in
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

					}
				}
			}

		bag += section.appendRow(title: "Norwegian bundle")
			.onValue {
				presentOffer {
					QueryMock(GraphQL.QuoteBundleQuery.self) { variables in
						.makeNorwegianBundle()
					}
				}
			}

		bag += section.appendRow(title: "Danish bundle")
			.onValue {
				presentOffer {
					QueryMock(GraphQL.QuoteBundleQuery.self) { variables in
						.makeDanishBundle()
					}

					MutationMock(GraphQL.SignQuotesMutation.self) { operation in
						.init(signQuotes: .makeSimpleSignSession(id: "123"))
					}
				}
			}

		bag += section.appendRow(title: "Swedish apartment - moving flow")
			.onValue {
				presentOffer {
					QueryMock(GraphQL.QuoteBundleQuery.self) { _ in
						.makeSwedishApartmentMovingFlow()
					}
				}
			}

		bag += viewController.install(form)

		return (viewController, bag)
	}
}

extension Debug {
	@GraphQLMockBuilder var sharedMocks: some GraphQLMock {
		MutationMock(GraphQL.ChangeStartDateMutation.self, duration: 2) { operation in
			if operation.startDate
				== Calendar.current.date(byAdding: .day, value: 3, to: Date())?
				.localDateString
			{
				throw MockError.failed
			}

			return
				GraphQL.ChangeStartDateMutation.Data(
					editQuote: .makeCompleteQuote(startDate: operation.startDate)
				)
		}

		SubscriptionMock(
			GraphQL.SignStatusSubscription.self,
			timeline: { operation in
				TimelineEntry(
					after: 0,
					data: GraphQL.SignStatusSubscription.Data(
						signStatus: .init(
							status: .init(
								collectStatus: .init(
									status: .pending,
									code: "outstandingTransaction"
								),
								signState: .inProgress
							)
						)
					)
				)
				TimelineEntry(
					after: 5,
					data: GraphQL.SignStatusSubscription.Data(
						signStatus: .init(
							status: .init(
								collectStatus: .init(
									status: .pending,
									code: "userSign"
								),
								signState: .inProgress
							)
						)
					)
				)
				TimelineEntry(
					after: 10,
					data: GraphQL.SignStatusSubscription.Data(
						signStatus: .init(
							status: .init(
								collectStatus: .init(
									status: .failed,
									code: "userCancel"
								),
								signState: .failed
							)
						)
					)
				)
			}
		)

		MutationMock(GraphQL.RemoveStartDateMutation.self) { _ in
			GraphQL.RemoveStartDateMutation.Data(
				removeStartDate: .makeCompleteQuote(startDate: nil)
			)
		}

		MutationMock(GraphQL.CheckoutUpdateMutation.self, duration: 2) { operation in
			GraphQL.CheckoutUpdateMutation.Data(
				editQuote: .makeCompleteQuote(email: operation.email, ssn: operation.ssn)
			)
		}
	}
}
