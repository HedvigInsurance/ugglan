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

final class RenewalCardTests: XCTestCase {
	let bag = DisposeBag()

	override func setUp() {
		super.setUp()
		setupScreenShotTests()
	}

	func perform(_ body: JSONObject, assertions: @escaping (_ view: UIView) -> Void) {
		let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: body), store: .init())

		Dependencies.shared.add(module: Module { () -> ApolloClient in apolloClient })

		let card = RenewalCard()

		let waitForApollo = expectation(description: "wait for apollo")

		let (view, bag) = card.materialize(events: ViewableEvents(wasAddedCallbacker: .init()))
		self.bag += bag

		view.snp.makeConstraints { make in make.width.equalTo(400) }

		apolloClient.fetch(query: GraphQL.HomeQuery()).delay(by: 0.1)
			.onValue { _ in assertions(view)
				waitForApollo.fulfill()
			}

		wait(for: [waitForApollo], timeout: 1)
	}

	func testDoesShowCard() {
		perform(.makeActiveWithMultipleRenewals()) { view in XCTAssertNotEqual(view.subviews.count, 0)
			assertSnapshot(matching: view, as: .image)
		}
	}

	func testDoesShowSingleCard() {
		perform(.makeActiveWithRenewal()) { view in XCTAssertNotEqual(view.subviews.count, 0)
			assertSnapshot(matching: view, as: .image)
		}
	}

	func testDoesShowMultipleSingleCards() {
		perform(.makeActiveWithMultipleRenewalsOnSeparateDates()) { view in
			XCTAssertNotEqual(view.subviews.count, 0)
			assertSnapshot(matching: view, as: .image)
		}
	}

	func testDoesNotShowCard() { perform(.makeActive()) { view in XCTAssertEqual(view.subviews.count, 0) } }
}
