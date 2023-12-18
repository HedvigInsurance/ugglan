import Apollo
import Flow
import Form
import Foundation
import HomeTesting
import SnapshotTesting
import TestDependencies
import Testing
import TestingUtil
import XCTest
import hCore
import hCoreUI
import hGraphQL

@testable import Home

final class ImportantMessagesSectionTest: XCTestCase {
    let bag = DisposeBag()

    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }

    func testScreenshot() {
        let apolloClient = ApolloClient(
            networkTransport: MockNetworkTransport(body: .makeImportantMessages()),
            store: .init()
        )

        Dependencies.shared.add(module: Module { () -> ApolloClient in apolloClient })

        let importantMessagesSection = ImportantMessagesSection()

        let waitForApollo = expectation(description: "wait for apollo")

        let (view, bag) = importantMessagesSection.materialize(
            events: ViewableEvents(wasAddedCallbacker: .init())
        )
        self.bag += bag

        wait(for: [waitForApollo], timeout: 1)
    }
}
