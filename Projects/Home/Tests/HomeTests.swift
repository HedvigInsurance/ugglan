import Apollo
import Flow
import Foundation
import SnapshotTesting
import Testing
import TestingUtil
import XCTest
import hCore
import hCoreUI
import hGraphQL

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

    bag += window.present(Home(sections: []))

    let waitForApollo = expectation(description: "wait for apollo")

    apolloClient.fetch(query: GraphQL.HomeQuery()).delay(by: 0.5)
      .onValue { _ in assertions(window)
        waitForApollo.fulfill()
        self.bag.dispose()
      }

    wait(for: [waitForApollo], timeout: 2)
  }
}
