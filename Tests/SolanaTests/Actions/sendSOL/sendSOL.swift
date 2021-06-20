import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class sendSOL: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solanaSDK: Solana!
    var account: Account { try! solanaSDK.auth.account.get() }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .getWallets
        solanaSDK = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solanaSDK.auth.save(account).get()
        _ = try solanaSDK.requestAirdrop(account: account.publicKey.base58EncodedString, lamports: 100.toLamport(decimals: 9)).toBlocking().first()
    }
    
    func testSendSOLFromBalance() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try! solanaSDK.getBalance().toBlocking().first()
        XCTAssertNotNil(balance)

        let transactionId = try! solanaSDK.sendSOL(
            to: toPublicKey,
            amount: balance!/10
        ).toBlocking().first()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOL() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        let transactionId = try! solanaSDK.sendSOL(
            to: toPublicKey,
            amount: 0.001.toLamport(decimals: 9)
        ).toBlocking().first()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOLIncorrectDestination() {
        let toPublicKey = "XX"
        XCTAssertThrowsError(try solanaSDK.sendSOL(
            to: toPublicKey,
            amount: 0.001.toLamport(decimals: 9)
        ).toBlocking().first())
    }
    func testSendSOLBigAmmount() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        XCTAssertThrowsError(try solanaSDK.sendSOL(
            to: toPublicKey,
            amount: 9223372036854775808
        ).toBlocking().first())
    }
}
