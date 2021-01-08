import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
@testable import Home
import SnapshotTesting
import Testing
import TestingUtil
import XCTest

class HomeTests: XCTestCase {
    let bag = DisposeBag()

    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func testContractTerminatedState() {
        let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makeTerminatedInTheFuture()))

        Dependencies.shared.add(module: Module { () -> ApolloClient in
            apolloClient
        })

        let window = UIWindow()

        bag += window.present(Home())

        let waitForApollo = expectation(description: "wait for apollo")

        apolloClient.fetch(query: GraphQL.HomeQuery())
            .delay(by: 0.5)
            .onValue { _ in
                assertSnapshot(matching: window, as: .image)
                waitForApollo.fulfill()
                self.bag.dispose()
            }

        wait(for: [waitForApollo], timeout: 2)
    }

    func testContractActiveInFutureState() {
        let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makeActiveInFuture(switchable: true)))

        Dependencies.shared.add(module: Module { () -> ApolloClient in
            apolloClient
        })

        let window = UIWindow()

        bag += window.present(Home())

        let waitForApollo = expectation(description: "wait for apollo")

        apolloClient.fetch(query: GraphQL.HomeQuery())
            .delay(by: 0.5)
            .onValue { _ in
                assertSnapshot(matching: window, as: .image)
                waitForApollo.fulfill()
                self.bag.dispose()
            }

        wait(for: [waitForApollo], timeout: 2)
    }

    func testContractActiveState() {
        let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makeActive()))

        Dependencies.shared.add(module: Module { () -> ApolloClient in
            apolloClient
        })

        let window = UIWindow()

        bag += window.present(Home())

        let waitForApollo = expectation(description: "wait for apollo")

        apolloClient.fetch(query: GraphQL.HomeQuery())
            .delay(by: 0.5)
            .onValue { _ in
                assertSnapshot(matching: window, as: .image)
                waitForApollo.fulfill()
                self.bag.dispose()
            }

        wait(for: [waitForApollo], timeout: 2)
    }
}
