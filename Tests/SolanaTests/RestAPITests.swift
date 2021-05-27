//
//  DevnetRestAPITests.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import XCTest
import RxSwift
import RxBlocking
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
        let token = "6AR3iMmnkP2U6ETecZviYEXnyiomeFwru7kftwSENmgK"
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
        let USDCWallet = "2tWC4JAdL4AxEFJySziYJfsAnW2MHKRo98vbAPiRDSk8"
        let USDTWallet = "EJwZgeZrdC8TXTQbQBoL6bfuAnFUUy1PVCMB4DYPzVaS"

        let USDCMintAddress = "2ST2CedQ1QT7f2G31Qws9n7GFj7C56fKnhbxnvLymFwU"
        let USDTMintAddress = "E9ySnfyR467236FjUQKswrXq1qmHmS7WyjbiWo7Fnmgo"
        
        let source = try Solana.PublicKey(string: USDCWallet)
        let sourceMint = try Solana.PublicKey(string: USDCMintAddress)
        let destination = try Solana.PublicKey(string: USDTWallet)
        let destinationMint = try Solana.PublicKey(string: USDTMintAddress)

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
            mintAddress: "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH",
            decimals: 6,
            from: "8hoBQbSFKfDK3Mo7Wwc15Pp2bbkYuJE8TdQmnHNDjXoQ",
            to: "8hoBQbSFKfDK3Mo7Wwc15Pp2bbkYuJE8TdQmnHNDjXoQ",
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
