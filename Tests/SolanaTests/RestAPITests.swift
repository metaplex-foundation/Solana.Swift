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
            url: "https://api.devnet.solana.com",
            network: .devnet
        )
    }
    var solanaSDK: Solana!
    var account: Solana.Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = try Solana.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        try solanaSDK.accountStorage.save(account)
    }

    func testGetTokenAccountBalance() throws {
        let balance = try solanaSDK.getTokenAccountBalance(pubkey: "4PsGEFn43xc7ztymrt77XfUE4FespyNm6KuYYmsstz5L").toBlocking().first()
        XCTAssertNotNil(balance?.uiAmount)
        XCTAssertNotNil(balance?.amount)
        XCTAssertNotNil(balance?.decimals)
    }

}
