//
//  BTCExampleTests.swift
//  BTCExampleTests
//
//  Created by Krisakorn Amnajsatit on 12/6/2566 BE.
//

import XCTest
import RxSwift
@testable import BTCExample
final class BTCExampleTests: XCTestCase {

    var viewModel: BitcoinViewModel!

    override func setUp() {
        super.setUp()
        viewModel = BitcoinViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testIsValidPinCode() {
        XCTAssertTrue(viewModel.isValidPinCode("172839"))
        XCTAssertTrue(viewModel.isValidPinCode("112762"))
        XCTAssertTrue(viewModel.isValidPinCode("124578"))
        XCTAssertTrue(viewModel.isValidPinCode("887712"))
        
        XCTAssertFalse(viewModel.isValidPinCode("17283"))
        XCTAssertFalse(viewModel.isValidPinCode("111822"))
        XCTAssertFalse(viewModel.isValidPinCode("123743"))
        XCTAssertFalse(viewModel.isValidPinCode("112233"))
        XCTAssertFalse(viewModel.isValidPinCode("882211"))
    }
}
