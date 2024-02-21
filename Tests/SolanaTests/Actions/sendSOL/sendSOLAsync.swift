import XCTest
import Solana

@available(iOS 13.0, *)
@available(macOS 10.15, *)
class sendSOLAsync: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: SolanaCore!
    var signer: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = SolanaCore(router: NetworkingRouter(endpoint: endpoint))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))! // 5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx
    }
    
    func testSendSOLFromBalance() async throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try await solana.api.getBalance(account: signer.publicKey.base58EncodedString, commitment: nil)
        XCTAssertNotNil(balance)

        let transactionId = try await solana.action.sendSOL(
            to: toPublicKey,
            from: signer,
            amount: balance/10
        )
        XCTAssertNotNil(transactionId)
    }
    
    func testSendSOL() async throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        let transactionId = try await solana.action.sendSOL(
            to: toPublicKey,
            from: signer,
            amount: 0.001.toLamport(decimals: 9)
        )
        XCTAssertNotNil(transactionId)
    }
    func testSendSOLIncorrectDestination() async {
        let toPublicKey = "XX"
        await asyncAssertThrowing("sendSOL should fail when destination is incorrect") {
            try await solana.action.sendSOL(
                to: toPublicKey,
                from: signer,
                amount: 0.001.toLamport(decimals: 9)
            )
        }
    }
    func testSendSOLBigAmmount() async {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        await asyncAssertThrowing("sendSOL should fail when amount is too big") {
            try await solana.action.sendSOL(
                to: toPublicKey,
                from: signer,
                amount: 9223372036854775808
            )
        }

    }
}
