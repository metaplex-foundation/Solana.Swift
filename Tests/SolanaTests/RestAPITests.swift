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
        let tokenAddress = "8hoBQbSFKfDK3Mo7Wwc15Pp2bbkYuJE8TdQmnHNDjXoQ"
        let balance = try solanaSDK.getTokenAccountBalance(pubkey: tokenAddress).toBlocking().first()
        XCTAssertNotNil(balance?.uiAmount)
        XCTAssertNotNil(balance?.amount)
        XCTAssertNotNil(balance?.decimals)
    }

}

// RestAPITransactionHistoryTests

extension RestAPITests {
    func testGetConfirmedSignaturesForAddress() throws {
        let result = try solanaSDK.getConfirmedSignaturesForAddress2(account: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx", configs: Solana.RequestConfiguration(limit: 10)).toBlocking().first()
        XCTAssertEqual(result?.count, 10)
    }

    func testGetConfirmedTransaction() throws {
        let result = try solanaSDK.getConfirmedTransaction(transactionSignature: "5dxrTLhZGwPzaYyE7xpTh5HgQdyV6hnseKGDHuhKAeTapw2TbTHtNh1aA2ecrbbGM2ZQ5gD6G7jzcd98Vro5L1DU").toBlocking().first()
        XCTAssertNotNil(result)
    }
}

// RestAPITransactionTests
extension RestAPITests {
    // MARK: - Create and close
    func testCreateTokenAccount() throws {
        let mintAddress = "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH"

        _ = try solanaSDK.createTokenAccount(
            mintAddress: mintAddress
        ).toBlocking().first()
    }

    func testCloseAccount() throws {
        let token = "FoDrW4UjZaUKxvEZprytrvF8T3zUzroM2smH9y6Z3t7y"
        _ = try solanaSDK.closeTokenAccount(
            tokenPubkey: token
        ).toBlocking().first()
    }

    // MARK: - Send
    func testSendSOLWithFee() throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try solanaSDK.getBalance().toBlocking().first()
        XCTAssertNotNil(balance)

        _ = try solanaSDK.sendSOL(
            to: toPublicKey,
            amount: balance!/10
        ).toBlocking().first()
    }

    func testSendSOLWithoutFee() throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        _ = try solanaSDK.sendSOL(
            to: toPublicKey,
            amount: 0.001.toLamport(decimals: 9)
        ).toBlocking().first()
    }

    func testSendSPLTokenWithFee() throws {
        let mintAddress = "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH"
        let source = "8hoBQbSFKfDK3Mo7Wwc15Pp2bbkYuJE8TdQmnHNDjXoQ"
        let destination = "8Poh9xusEcKtmYZ9U4FSfjrrrQR155TLWGAsyFWjjKxB"

        _ = try solanaSDK.sendSPLTokens(
            mintAddress: mintAddress,
            decimals: 5,
            from: source,
            to: destination,
            amount: Double(0.001).toLamport(decimals: 5)
        ).toBlocking().first()
        
        _ = try solanaSDK.sendSPLTokens(
            mintAddress: mintAddress,
            decimals: 5,
            from: destination,
            to: source,
            amount: Double(0.001).toLamport(decimals: 5)
        ).toBlocking().first()
    }

    func testSwapToken() throws {
        let source = try Solana.PublicKey(string: "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm")
        let sourceMint = Solana.PublicKey.wrappedSOLMint
        let destinationMint = try Solana.PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")
        let destination = try Solana.PublicKey(string: "C3enVPXBvpx7AWGZkqhn7xCcoxCrDCZy9hZ1e5qyoWo6")

        _ = try solanaSDK.swap(
            source: source,
            sourceMint: sourceMint,
            destination: destination,
            destinationMint: destinationMint,
            slippage: 0.5,
            amount: 0.001.toLamport(decimals: 9)
        ).toBlocking().first()
    }

    func testSendSPLTokenToSolAccountViaAToken() throws {
        _ = try solanaSDK.sendSPLTokens(
            mintAddress: "MAPS41MDahZ9QdKXhVa4dWB9RuyfV4XqhyAZ8XcYepb",
            decimals: 6,
            from: "H1yu3R247X5jQN9bbDU8KB7RY4JSeEaCv45p5CMziefd",
            to: "J2EzmHcwZP4CUQwt9yUBgPS7JcMyJYCqw2WGVB5LTW6P",
            amount: 0.001.toLamport(decimals: 6)
        ).toBlocking().first()
    }
}

// RestAPIPoolTests
extension RestAPITests {
    func testGetPools() throws {
        let pools = try solanaSDK.getSwapPools().toBlocking().first()
        XCTAssertNotNil(pools)
        XCTAssertNotEqual(pools!.count, 0)
    }
}
