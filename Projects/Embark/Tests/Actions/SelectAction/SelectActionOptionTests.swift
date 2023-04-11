import Foundation
import SnapshotTesting
import TestDependencies
import Testing
import XCTest
import hGraphQL

@testable import Embark

final class SelectActionOptionTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func testSelectActionOption() {
        let selectActionOption = EmbarkSelectActionOption(
            state: .init(),
            data: GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction
                .SelectActionDatum.Option(
                    keys: ["test"],
                    values: ["test"],
                    link: GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
                        .AsEmbarkSelectAction.SelectActionDatum.Option.Link(
                            name: "somewhere",
                            hidden: false,
                            label: "This is a label"
                        )
                )
        )

        materializeViewable(selectActionOption) { view in
            view.snp.makeConstraints { make in make.width.equalTo(150) }

            ciAssertSnapshot(matching: view, as: .image)
        }
    }
}
