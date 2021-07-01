import Apollo
import ExampleUtil
import Flow
import Form
import Foundation
import Home
import HomeTesting
import Presentation
import TestingUtil
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct Debug {}

extension Debug: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		let bag = DisposeBag()
		let viewController = UIViewController()
		viewController.title = "HomeExample"

		let form = FormView()

		ContextGradient.currentOption = .home

		let section = form.appendSection(
			headerView: UILabel(value: "Screens", style: .default),
			footerView: nil
		)

		func presentHome(_ body: JSONObject) {
			let apolloClient = ApolloClient(
				networkTransport: MockNetworkTransport(body: body),
				store: ApolloStore()
			)

			Dependencies.shared.add(module: Module { () -> ApolloClient in apolloClient })

			bag += UIApplication.shared.keyWindow?
				.present(
					Home(sections: []),
					options: [
						.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always),
					]
				)
		}

		bag += section.appendRow(title: "Home - Active").append(hCoreUIAssets.chevronRight.image)
			.onValue { presentHome(.makeActive()) }

		bag += section.appendRow(title: "Home - Active in future").append(hCoreUIAssets.chevronRight.image)
			.onValue { presentHome(.makeActiveInFuture(switchable: true)) }

		bag += section.appendRow(title: "Home - Pending").append(hCoreUIAssets.chevronRight.image)
			.onValue { presentHome(.makePending(switchable: true)) }

		bag += section.appendRow(title: "Home - Pending non switchable")
			.append(hCoreUIAssets.chevronRight.image)
			.onValue { presentHome(.makePending(switchable: false)) }

		bag += section.appendRow(title: "Home - With payment card").append(hCoreUIAssets.chevronRight.image)
			.onValue { presentHome(combineMultiple([.makeActive(), .makePayInMethodStatus(.needsSetup)])) }

		bag += section.appendRow(title: "Renewals - One renewal").append(hCoreUIAssets.chevronRight.image)
			.onValue { presentHome(combineMultiple([.makeActiveWithRenewal()])) }

		bag += section.appendRow(title: "Renewals - Multiple same date")
			.append(hCoreUIAssets.chevronRight.image)
			.onValue { presentHome(.makeActiveWithMultipleRenewals()) }

		bag += section.appendRow(title: "Renewals - Multiple separate dates")
			.append(hCoreUIAssets.chevronRight.image)
			.onValue { presentHome(.makeActiveWithMultipleRenewalsOnSeparateDates()) }

		bag += viewController.install(form)

		return (viewController, bag)
	}
}
