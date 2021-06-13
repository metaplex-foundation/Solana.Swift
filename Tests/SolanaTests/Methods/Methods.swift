import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class Methods: XCTestCase {
    var endpoint = Solana.RpcApiEndPoint.devnetSolana
    var solanaSDK: Solana!
    var account: Solana.Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = try Solana.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        try solanaSDK.accountStorage.save(account)
    }

    func testGetAccountInfo() throws {
        let info: Solana.BufferInfo<Solana.AccountInfo>? = try solanaSDK.getAccountInfo(account: account.publicKey.base58EncodedString, decodedTo: Solana.AccountInfo.self).toBlocking().first()
        XCTAssertNotNil(info)
        XCTAssertNotNil(info?.data)
    }
        
    func testGetBlockCommitment() throws {
        let block = try solanaSDK.getBlockCommitment(block: 82493733).toBlocking().first()
        XCTAssertNotNil(block)
    }
  
    func testGetBalance() throws {
        let value = try solanaSDK.getBalance(account: account.publicKey.base58EncodedString).toBlocking().first()
        XCTAssertNotNil(value)
    }
    func testGetClusterNodes() throws {
        let nodes = try solanaSDK.getClusterNodes().toBlocking().first()
        XCTAssertNotNil(nodes)
    }
    func testGetBlockTime() throws {
        let date = try solanaSDK.getBlockCommitment(block: 61968801).toBlocking().first()
        XCTAssertNotNil(date)
    }
    func testGetConfirmedBlock() throws {
        let block = try solanaSDK.getConfirmedBlock(slot: 61998730).toBlocking().first()
        XCTAssertNotNil(block)
    }
    func testGetConfirmedBlocks() throws {
        let blocks = try solanaSDK.getConfirmedBlocks(startSlot:61998720, endSlot: 61998730).toBlocking().first()
        XCTAssertNotNil(blocks)
    }
    func testGetConfirmedBlocksWithLimit() throws {
        let blocks = try solanaSDK.getConfirmedBlocksWithLimit(startSlot:61998720, limit: 10).toBlocking().first()
        XCTAssertNotNil(blocks)
    }
    func testGetTokenAccountBalance() throws {
        let tokenAddress = "FzhfekYF625gqAemjNZxjgTZGwfJpavMZpXCLFdypRFD"
        let balance = try solanaSDK.getTokenAccountBalance(pubkey: tokenAddress).toBlocking().first()
        XCTAssertNotNil(balance?.uiAmount)
        XCTAssertNotNil(balance?.amount)
        XCTAssertNotNil(balance?.decimals)
    }
    func testGetConfirmedSignaturesForAddress() throws {
        let signatures = try solanaSDK.getConfirmedSignaturesForAddress(account: "Vote111111111111111111111111111111111111111", startSlot: 61968701, endSlot: 61968801).toBlocking().first()
        XCTAssertNotNil(signatures)
    }
    func testGetConfirmedSignaturesForAddress2() throws {
        let result = try solanaSDK.getConfirmedSignaturesForAddress2(account: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx", configs: Solana.RequestConfiguration(limit: 10)).toBlocking().first()
        XCTAssertEqual(result?.count, 10)
    }
    func testGetConfirmedTransaction() throws {
        let result = try solanaSDK.getConfirmedTransaction(transactionSignature: "5dxrTLhZGwPzaYyE7xpTh5HgQdyV6hnseKGDHuhKAeTapw2TbTHtNh1aA2ecrbbGM2ZQ5gD6G7jzcd98Vro5L1DU").toBlocking().first()
        XCTAssertNotNil(result)
    }
    func testGetEpochInfo() throws {
        let epoch = try solanaSDK.getEpochInfo().toBlocking().first()
        XCTAssertNotNil(epoch)
    }
    func testGetEpochSheadule() throws {
        let epoch = try solanaSDK.getEpochSchedule().toBlocking().first()
        XCTAssertNotNil(epoch)
    }
}

// RestAPITransactionTests
extension Methods {
    // MARK: - Create and close
    func testCreateTokenAccount() throws {
        let mintAddress = "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH"

        _ = try solanaSDK.createTokenAccount(
            mintAddress: mintAddress
        ).toBlocking().first()
    }

    /*func testCloseAccount() throws {
        let token = "7KxA7JU6MueQqQwMXZ4PTBB1ov9C7UfPa4RLiDxuHGsx"
        _ = try solanaSDK.closeTokenAccount(
            tokenPubkey: token
        ).toBlocking().first()
    }*/

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

/*func testSwapToken() throws {
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
    }*/

    /*func testSendSPLTokenToSolAccountViaAToken() throws {
        _ = try solanaSDK.sendSPLTokens(
            mintAddress: "So11111111111111111111111111111111111111112",
            decimals: 6,
            from: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx",
            to: "5Tg8VjmWQPgnEWDLACH5B3WsYAGhsQwsrWgFb4NaTPYZ",
            amount: 0.001.toLamport(decimals: 6)
        ).toBlocking().first()
    }*/
}

// RestAPIPoolTests
extension Methods {
    func testGetPools() throws {
        let pools = try solanaSDK.getSwapPools().toBlocking().first()
        XCTAssertNotNil(pools)
        XCTAssertNotEqual(pools!.count, 0)
    }
}
