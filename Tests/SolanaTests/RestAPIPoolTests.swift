//
//  RestAPIPoolTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 26/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import Solana

class RestAPIPoolTests: RestAPITests {
    func testGetPools() throws {
        let pools = try solanaSDK.getSwapPools().toBlocking().first()
        XCTAssertNotNil(pools)
        XCTAssertNotEqual(pools!.count, 0)
    }
}
