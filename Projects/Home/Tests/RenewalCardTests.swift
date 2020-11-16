import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
@testable import Home
import HomeTesting
import SnapshotTesting
import Testing
import TestingUtil
import XCTest

final class RenewalCardTests: XCTestCase {
    let bag = DisposeBag()

    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func testDoesShowCard() {
        let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makeActiveWithMultipleRenewals()))

        Dependencies.shared.add(module: Module { () -> ApolloClient in
            apolloClient
        })

        let card = RenewalCard()

        let waitForApollo = expectation(description: "wait for apollo")

        let (view, bag) = card.materialize(events: ViewableEvents(wasAddedCallbacker: .init()))
        self.bag += bag

        view.snp.makeConstraints { make in
            make.width.equalTo(300)
        }

        apolloClient.fetch(query: GraphQL.HomeQuery()).delay(by: 0.1).onValue { _ in
            XCTAssertNotEqual(view.subviews.count, 0)
            assertSnapshot(matching: view, as: .image)
            waitForApollo.fulfill()
        }

        wait(for: [waitForApollo], timeout: 1)
    }

    func testDoesShowSingleCard() {
        let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makeActiveWithRenewal()))

        Dependencies.shared.add(module: Module { () -> ApolloClient in
            apolloClient
        })

        let card = RenewalCard()

        let waitForApollo = expectation(description: "wait for apollo")

        let (view, bag) = card.materialize(events: ViewableEvents(wasAddedCallbacker: .init()))
        self.bag += bag

        view.snp.makeConstraints { make in
            make.width.equalTo(300)
        }

        apolloClient.fetch(query: GraphQL.HomeQuery()).delay(by: 0.1).onValue { _ in
            XCTAssertNotEqual(view.subviews.count, 0)
            assertSnapshot(matching: view, as: .image)
            waitForApollo.fulfill()
        }

        wait(for: [waitForApollo], timeout: 1)
    }

    func testDoesShowMultipleSingleCards() {
        let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makeActiveWithMultipleRenewalsOnSeparateDates()))

        Dependencies.shared.add(module: Module { () -> ApolloClient in
            apolloClient
        })

        let card = RenewalCard()

        let waitForApollo = expectation(description: "wait for apollo")

        let (view, bag) = card.materialize(events: ViewableEvents(wasAddedCallbacker: .init()))
        self.bag += bag

        view.snp.makeConstraints { make in
            make.width.equalTo(400)
        }

        apolloClient.fetch(query: GraphQL.HomeQuery()).delay(by: 0.1).onValue { _ in
            XCTAssertNotEqual(view.subviews.count, 0)
            assertSnapshot(matching: view, as: .image)
            waitForApollo.fulfill()
        }

        wait(for: [waitForApollo], timeout: 1)
    }

    func testDoesNotShowCard() {
        let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makeActive()))

        Dependencies.shared.add(module: Module { () -> ApolloClient in
            apolloClient
        })

        let card = RenewalCard()

        let waitForApollo = expectation(description: "wait for apollo")

        let (view, bag) = card.materialize(events: ViewableEvents(wasAddedCallbacker: .init()))
        self.bag += bag

        apolloClient.fetch(query: GraphQL.HomeQuery()).delay(by: 0.1).onValue { _ in
            XCTAssertEqual(view.subviews.count, 0)
            waitForApollo.fulfill()
        }

        wait(for: [waitForApollo], timeout: 1)
    }
}
