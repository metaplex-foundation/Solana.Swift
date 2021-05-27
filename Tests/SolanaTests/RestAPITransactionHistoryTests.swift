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
        let result = try solanaSDK.getConfirmedSignaturesForAddress2(account: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx", configs: Solana.RequestConfiguration(limit: 10)).toBlocking().first()
        XCTAssertEqual(result?.count, 10)
    }

    func testGetConfirmedTransaction() throws {
        let result = try solanaSDK.getConfirmedTransaction(transactionSignature: "5dxrTLhZGwPzaYyE7xpTh5HgQdyV6hnseKGDHuhKAeTapw2TbTHtNh1aA2ecrbbGM2ZQ5gD6G7jzcd98Vro5L1DU").toBlocking().first()
        XCTAssertNotNil(result)
    }
}
