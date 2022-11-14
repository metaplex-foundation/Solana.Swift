import XCTest
import Solana

class sendSPLTokens: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var signer: Signer!
    
    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = Solana(router: NetworkingRouter(endpoint: endpoint))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
        _ = try solana.api.requestAirdrop(account: signer.publicKey.base58EncodedString, lamports: 100.toLamport(decimals: 9))?.get()
    }
    
    func testSendSPLTokenWithFee() {
        let mintAddress = "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH"
        let source = "8hoBQbSFKfDK3Mo7Wwc15Pp2bbkYuJE8TdQmnHNDjXoQ"
        let destination = "8Poh9xusEcKtmYZ9U4FSfjrrrQR155TLWGAsyFWjjKxB"
        
        let transactionId = try! solana.action.sendSPLTokens(
            mintAddress: mintAddress,
            decimals: 5,
            from: source,
            to: destination,
            amount: Double(0.001).toLamport(decimals: 5),
            payer: signer
        )?.get()
        XCTAssertNotNil(transactionId)
        
        let transactionIdB = try! solana.action.sendSPLTokens(
            mintAddress: mintAddress,
            decimals: 5,
            from: destination,
            to: source,
            amount: Double(0.001).toLamport(decimals: 5),
            payer: signer
        )?.get()
        XCTAssertNotNil(transactionIdB)
    }
}
