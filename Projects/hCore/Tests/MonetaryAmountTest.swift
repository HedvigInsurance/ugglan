//
//  MonetaryAmountTest.swift
//  hCoreTests
//
//  Created by sam on 8.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
@testable import hCore
import XCTest

final class MonetaryAmountTests: XCTestCase {
    func testFormattedAmount() {
        let sekAmount = MonetaryAmount(amount: "100.0", currency: "SEK")
        XCTAssertEqual(sekAmount.formattedAmount, "100 kr")

        let nokAmount = MonetaryAmount(amount: "100.0", currency: "NOK")
        XCTAssertEqual(nokAmount.formattedAmount, "kr 100")

        let unknownAmount = MonetaryAmount(amount: "100.0", currency: "USD")
        XCTAssertEqual(unknownAmount.formattedAmount, "$100")
    }
}
