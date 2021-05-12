import Foundation
import hGraphQL
import SnapshotTesting
import Testing
import XCTest

@testable import Embark

final class SelectActionOptionTests: XCTestCase {
	override func setUp() {
		super.setUp()
		setupScreenShotTests()
	}

	func testSelectActionOption() {
		let selectActionOption = EmbarkSelectActionOption(
			data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction
				.SelectActionDatum.Option(
					keys: ["test"],
					values: ["test"],
					link: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
						.AsEmbarkSelectAction.SelectActionDatum.Option.Link(
							name: "somewhere",
							label: "This is a label"
						)
				)
		)

		materializeViewable(selectActionOption) { view in
			view.snp.makeConstraints { make in make.width.equalTo(150) }

			assertSnapshot(matching: view, as: .image)
		}
	}
}
