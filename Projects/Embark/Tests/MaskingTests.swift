//
//  MaskingTests.swift
//  EmbarkTests
//
//  Created by sam on 23.7.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

@testable import Embark
import Foundation
import XCTest

final class MaskingTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testShouldRemoveDelimiter() {
        let masking = Masking(type: .birthDate)
        XCTAssertEqual(masking.maskValue(text: "1993-", previousText: "1993-0"), "1993")
    }

    func testPersonalNumber() {
        let masking = Masking(type: .personalNumber)
        XCTAssertEqual(masking.maskValue(text: "1258475847", previousText: ""), "125847-5847")
        XCTAssertEqual(masking.maskValue(text: "191258475847", previousText: ""), "19125847-5847")
        XCTAssertEqual(masking.maskValue(text: "201258475847", previousText: ""), "20125847-5847")
        XCTAssertEqual(masking.maskValue(text: "4725486", previousText: ""), "472548-6")
    }
    
    func testBirthDate() {
        let masking = Masking(type: .birthDate)
        XCTAssertEqual(masking.maskValue(text: "19880210", previousText: ""), "1988-02-10")
    }
    
    func testBirthDateReverse() {
        let masking = Masking(type: .birthDateReverse)
        XCTAssertEqual(masking.maskValue(text: "10-02-1988", previousText: ""), "10-02-1988")
        XCTAssertEqual(masking.unmaskedValue(text: "10-02-1988"), "1988-02-10")
    }
    
    func testDigits() {
        let masking = Masking(type: .digits)
        XCTAssertEqual(masking.maskValue(text: "888abc", previousText: ""), "888")
    }
    
    func testPostalCode() {
        let masking = Masking(type: .postalCode)
        XCTAssertEqual(masking.maskValue(text: "70354", previousText: ""), "703 54")
        XCTAssertEqual(masking.maskValue(text: "703-54", previousText: ""), "703 54")
        XCTAssertEqual(masking.maskValue(text: "703-546", previousText: "703 54"), "703 54")
    }
    
    func testNorwegianPostalCode() {
        let masking = Masking(type: .norwegianPostalCode)
        XCTAssertEqual(masking.maskValue(text: "1234", previousText: ""), "1234")
        XCTAssertEqual(masking.maskValue(text: "12 4", previousText: ""), "124")
    }
    
    func testKeyboardTypes() {
        let maskingPersonalNumber = Masking(type: .personalNumber)
        XCTAssertEqual(maskingPersonalNumber.keyboardType, UIKeyboardType.numberPad)
        XCTAssertNil(maskingPersonalNumber.textContentType)
        
        let maskingEmail = Masking(type: .email)
        XCTAssertEqual(maskingEmail.textContentType, UITextContentType.emailAddress)
        XCTAssertEqual(maskingEmail.keyboardType, UIKeyboardType.emailAddress)
    }
}

