import XCTest
import Solana

class sendSOL: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: SolanaCore!
    var signer: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = SolanaCore(router: NetworkingRouter(endpoint: endpoint))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))! // 5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx
    }
    
    func testSendSOLFromBalance() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try! solana.api.getBalance(account: signer.publicKey.base58EncodedString)?.get()
        XCTAssertNotNil(balance)

        let transactionId = try! solana.action.sendSOL(
            to: toPublicKey,
            amount: balance!/10,
            from: signer
        )?.get()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOL() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        let transactionId = try! solana.action.sendSOL(
            to: toPublicKey,
            amount: 0.001.toLamport(decimals: 9),
            from: signer
            ,allowUnfundedRecipient: true
        )?.get()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOLIncorrectDestination() {
        let toPublicKey = "XX"
        XCTAssertThrowsError(try solana.action.sendSOL(
            to: toPublicKey,
            amount: 0.001.toLamport(decimals: 9),
            from: signer
        )?.get())
    }
    func testSendSOLBigAmmount() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        XCTAssertThrowsError(try solana.action.sendSOL(
            to: toPublicKey,
            amount: 9223372036854775808,
            from: signer
        )?.get())
    }
}
