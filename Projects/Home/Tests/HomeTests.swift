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

    func perform(
        _ body: JSONObject,
        assertions: @escaping (_ view: UIView) -> Void
    ) {
        let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: body), store: .init())

        Dependencies.shared.add(module: Module { () -> ApolloClient in
            apolloClient
        })

        let window = UIWindow()

        bag += window.present(Home())

        let waitForApollo = expectation(description: "wait for apollo")

        apolloClient.fetch(query: GraphQL.HomeQuery())
            .delay(by: 0.5)
            .onValue { _ in
                assertions(window)
                waitForApollo.fulfill()
                self.bag.dispose()
            }

        wait(for: [waitForApollo], timeout: 2)
    }

    func testContractTerminatedState() {
        perform(.makeTerminatedInTheFuture()) { window in
            assertSnapshot(matching: window, as: .image)
        }
    }

    func testContractActiveInFutureState() {
        perform(.makeActiveInFuture(switchable: true)) { window in
            assertSnapshot(matching: window, as: .image)
        }
    }

    func testContractActiveState() {
        perform(.makeActive()) { window in
            assertSnapshot(matching: window, as: .image)
        }
    }
}
