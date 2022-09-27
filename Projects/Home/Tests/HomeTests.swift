import Apollo
import Flow
import Foundation
import Presentation
import SnapshotTesting
import SwiftUI
import Testing
import TestingUtil
import XCTest
import hCore
import hCoreUI
import hGraphQL
import TestDependencies

@testable import Home

class HomeTests: XCTestCase {
    let bag = DisposeBag()

    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func perform(_ body: JSONObject, assertions: @escaping (_ view: UIView) -> Void) {
        let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: body), store: .init())

        Dependencies.shared.add(module: Module { () -> ApolloClient in apolloClient })

        let window = UIWindow()

        bag += window.present(
            Journey(
                Home(
                    claimsContent: EmptyView(),
                    commonClaims: EmptyView(),
                    {

                    }
                ),
                options: [
                    .defaults, .prefersLargeTitles(true),
                    .largeTitleDisplayMode(.always),
                ]
            ) { result in
                return DismissJourney()
            }
        )

        let waitForApollo = expectation(description: "wait for apollo")

        apolloClient.fetch(query: GraphQL.HomeQuery()).delay(by: 0.5)
            .onValue { _ in assertions(window)
                waitForApollo.fulfill()
                self.bag.dispose()
            }

        wait(for: [waitForApollo], timeout: 2)
    }
}
