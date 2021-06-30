import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class sendSPLTokens: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var account: Account { try! solana.auth.account.get() }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solana.auth.save(account).get()
        _ = try solana.api.requestAirdrop(account: account.publicKey.base58EncodedString, lamports: 100.toLamport(decimals: 9)).toBlocking().first()
    }
    
    func testSendSPLTokenWithFee() {
        let mintAddress = PublicKey(string: "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH")!
        let source = PublicKey(string: "8hoBQbSFKfDK3Mo7Wwc15Pp2bbkYuJE8TdQmnHNDjXoQ")!
        let destination = PublicKey(string: "8Poh9xusEcKtmYZ9U4FSfjrrrQR155TLWGAsyFWjjKxB")!

        let transactionId = try! solana.action.sendSPLTokens(
            mintAddress: mintAddress,
            decimals: 5,
            from: source,
            to: destination,
            amount: Double(0.001).toLamport(decimals: 5)
        ).toBlocking().first()
        XCTAssertNotNil(transactionId)
        
        let transactionIdB = try! solana.action.sendSPLTokens(
            mintAddress: mintAddress,
            decimals: 5,
            from: destination,
            to: source,
            amount: Double(0.001).toLamport(decimals: 5)
        ).toBlocking().first()
        XCTAssertNotNil(transactionIdB)
    }
}
