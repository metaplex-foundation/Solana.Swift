//
//  RestAPITransactionHistoryTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 30/11/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import RxBlocking
@testable import Solana

class RestAPITransactionHistoryTests: RestAPITests {
    func testGetConfirmedSignaturesForAddress() throws {
        let result = try solanaSDK.getConfirmedSignaturesForAddress2(account: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG", configs: Solana.RequestConfiguration(limit: 10)).toBlocking().first()
        XCTAssertEqual(result?.count, 10)
    }

    func testGetConfirmedTransaction() throws {
        let result = try solanaSDK.getConfirmedTransaction(transactionSignature: "2dy6y54mVBx2jZQef4xCLcDFS4tmLLScDJA7PQvfcxLMiEH1aTHFDXgRwFmurFpFQ8tz1TGAGQbon7AvsfyiFWfK").toBlocking().first()
        XCTAssertNotNil(result)
    }
}
