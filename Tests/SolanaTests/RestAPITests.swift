//
//  DevnetRestAPITests.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import XCTest
@testable import Solana

class RestAPITests: XCTestCase {
    var endpoint: Solana.APIEndPoint {
        .init(
            url: "https://api.mainnet-beta.solana.com",
            network: .mainnetBeta
        )
    }
    var solanaSDK: Solana!
    var account: Solana.Account {solanaSDK.accountStorage.account!}

    override func setUpWithError() throws {
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = try Solana.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        try solanaSDK.accountStorage.save(account)
    }

    func testGetTokenAccountBalance() throws {
        let balance = try solanaSDK.getTokenAccountBalance(pubkey: "1dmDx6xPCaHE3wBTyGLASy3BHuvNVFiVBvrtg4X9sxa").toBlocking().first()
        XCTAssertNotNil(balance?.uiAmount)
        XCTAssertNotNil(balance?.amount)
        XCTAssertNotNil(balance?.decimals)
    }

}
