import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class sendSPLTokens: XCTestCase {
    var endpoint = Solana.RpcApiEndPoint.devnetSolana
    var solanaSDK: Solana!
    var account: Solana.Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = Solana.Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solanaSDK.accountStorage.save(account).get()
        _ = try solanaSDK.requestAirdrop(account: account.publicKey.base58EncodedString, lamports: 100.toLamport(decimals: 9)).toBlocking().first()
    }
    
    func testSendSPLTokenWithFee() {
        let mintAddress = "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH"
        let source = "8hoBQbSFKfDK3Mo7Wwc15Pp2bbkYuJE8TdQmnHNDjXoQ"
        let destination = "8Poh9xusEcKtmYZ9U4FSfjrrrQR155TLWGAsyFWjjKxB"

        let transactionId = try! solanaSDK.sendSPLTokens(
            mintAddress: mintAddress,
            decimals: 5,
            from: source,
            to: destination,
            amount: Double(0.001).toLamport(decimals: 5)
        ).toBlocking().first()
        XCTAssertNotNil(transactionId)
        
        let transactionIdB = try! solanaSDK.sendSPLTokens(
            mintAddress: mintAddress,
            decimals: 5,
            from: destination,
            to: source,
            amount: Double(0.001).toLamport(decimals: 5)
        ).toBlocking().first()
        XCTAssertNotNil(transactionIdB)
    }
}
