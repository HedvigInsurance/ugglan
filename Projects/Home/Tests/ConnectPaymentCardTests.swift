import Apollo
import Flow
import Foundation
import HomeTesting
import SnapshotTesting
import Testing
import TestingUtil
import XCTest
import hCore
import hCoreUI
import hGraphQL

@testable import Home

final class ConnectPaymentCardTests: XCTestCase {
	let bag = DisposeBag()

	override func setUp() {
		super.setUp()
		setupScreenShotTests()
	}

	func testDoesShowCard() {
		let apolloClient = ApolloClient(
			networkTransport: MockNetworkTransport(body: .makePayInMethodStatus(.needsSetup)),
			store: .init()
		)

		Dependencies.shared.add(module: Module { () -> ApolloClient in apolloClient })

		let card = ConnectPaymentCard()

		let waitForApollo = expectation(description: "wait for apollo")

		let (view, bag) = card.materialize()
		self.bag += bag

		apolloClient.fetch(query: GraphQL.PayInMethodStatusQuery()).delay(by: 0.1)
			.onValue { _ in XCTAssertNotEqual(view.subviews.count, 0)
				waitForApollo.fulfill()
			}

		wait(for: [waitForApollo], timeout: 1)
	}

	func testDoesNotShowCard() {
		let apolloClient = ApolloClient(
			networkTransport: MockNetworkTransport(body: .makePayInMethodStatus(.active)),
			store: .init()
		)

		Dependencies.shared.add(module: Module { () -> ApolloClient in apolloClient })

		let card = ConnectPaymentCard()

		let waitForApollo = expectation(description: "wait for apollo")

		let (view, bag) = card.materialize()
		self.bag += bag

		apolloClient.fetch(query: GraphQL.PayInMethodStatusQuery()).delay(by: 0.1)
			.onValue { _ in XCTAssertEqual(view.subviews.count, 0)
				waitForApollo.fulfill()
			}

		wait(for: [waitForApollo], timeout: 1)
	}
}
