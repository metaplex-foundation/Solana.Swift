import XCTest
import Solana

class sendSOL: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var account: Account { try! solana.auth.account.get() }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .getWallets
        solana = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solana.auth.save(account).get()
    }
    
    func testSendSOLFromBalance() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try! solana.api.getBalance()?.get()
        XCTAssertNotNil(balance)

        let transactionId = try! solana.action.sendSOL(
            to: toPublicKey,
            amount: balance!/10
        )?.get()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOL() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        let transactionId = try! solana.action.sendSOL(
            to: toPublicKey,
            amount: 0.001.toLamport(decimals: 9)
        )?.get()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOLIncorrectDestination() {
        let toPublicKey = "XX"
        XCTAssertThrowsError(try solana.action.sendSOL(
            to: toPublicKey,
            amount: 0.001.toLamport(decimals: 9)
        )?.get())
    }
    func testSendSOLBigAmmount() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        XCTAssertThrowsError(try solana.action.sendSOL(
            to: toPublicKey,
            amount: 9223372036854775808
        )?.get())
    }
}
