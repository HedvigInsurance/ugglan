//
//  SelectActionOptionTests.swift
//  EmbarkTests
//
//  Created by sam on 26.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

@testable import Embark
import Foundation
import SnapshotTesting
import Testing
import XCTest

final class SelectActionOptionTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func testSelectActionOption() {
        let selectActionOption = EmbarkSelectActionOption(
            data: EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction.SelectActionDatum.Option(
                keys: ["test"],
                values: ["test"],
                link: EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction.SelectActionDatum.Option.Link(
                    name: "somewhere",
                    label: "This is a label"
                )
            )
        )

        materializeViewable(selectActionOption) { view in
            view.snp.makeConstraints { make in
                make.width.equalTo(150)
            }

            assertSnapshot(matching: view, as: .image)
        }
    }
}
