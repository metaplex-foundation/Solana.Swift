//
//  SolanaTokensListParserTests.swift
//  solana-token-list-swift_Tests
//
//  Created by Chung Tran on 21/04/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import Solana

class SolanaTokensListParserTests: XCTestCase {
    var parser: Solana.TokensListParser!
    var list: [Solana.Token]!

    override func setUpWithError() throws {
        parser = Solana.TokensListParser()
        list = try parser.parse(network: Solana.Network.mainnetBeta.cluster)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParsing() throws {
        // List count must be equal to 396 after removing duppicated items
        XCTAssertEqual(list.count, 396)

        // Tags must be parsed
        XCTAssertEqual(list[2].tags.count, 2)
    }
}
