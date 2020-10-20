import Apollo
import Flow
import Form
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

final class ImportantMessagesSectionTest: XCTestCase {
    let bag = DisposeBag()

    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }

    func testScreenshot() {
        let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: .makeImportantMessages()))

        Dependencies.shared.add(module: Module { () -> ApolloClient in
            apolloClient
        })

        let importantMessagesSection = ImportantMessagesSection()

        let waitForApollo = expectation(description: "wait for apollo")

        let (view, bag) = importantMessagesSection.materialize(events: ViewableEvents(wasAddedCallbacker: .init()))
        self.bag += bag

        apolloClient.fetch(query: GraphQL.ImportantMessagesQuery(langCode: "")).delay(by: 0.1).onValue { _ in
            view.snp.makeConstraints { make in
                make.width.equalTo(400)
            }

            assertSnapshot(matching: view, as: .image)
            waitForApollo.fulfill()
        }

        wait(for: [waitForApollo], timeout: 1)
    }
}
