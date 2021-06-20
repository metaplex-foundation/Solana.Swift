import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class sendSOL: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var account: Account { try! solana.auth.account.get() }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .getWallets
        solana = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solana.auth.save(account).get()
        _ = try solana.api.requestAirdrop(account: account.publicKey.base58EncodedString, lamports: 100.toLamport(decimals: 9)).toBlocking().first()
    }
    
    func testSendSOLFromBalance() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try! solana.api.getBalance().toBlocking().first()
        XCTAssertNotNil(balance)

        let transactionId = try! solana.action.sendSOL(
            to: toPublicKey,
            amount: balance!/10
        ).toBlocking().first()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOL() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        let transactionId = try! solana.action.sendSOL(
            to: toPublicKey,
            amount: 0.001.toLamport(decimals: 9)
        ).toBlocking().first()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOLIncorrectDestination() {
        let toPublicKey = "XX"
        XCTAssertThrowsError(try solana.action.sendSOL(
            to: toPublicKey,
            amount: 0.001.toLamport(decimals: 9)
        ).toBlocking().first())
    }
    func testSendSOLBigAmmount() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        XCTAssertThrowsError(try solana.action.sendSOL(
            to: toPublicKey,
            amount: 9223372036854775808
        ).toBlocking().first())
    }
}
