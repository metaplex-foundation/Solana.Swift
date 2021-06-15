import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class createTokenAccount: XCTestCase {
    var endpoint = Solana.RpcApiEndPoint.devnetSolana
    var solanaSDK: Solana!
    var account: Solana.Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = try Solana.Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)
        try solanaSDK.accountStorage.save(account)
    }
    
    func testCreateTokenAccount() throws {
        let mintAddress = "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH"
        let account = try solanaSDK.createTokenAccount( mintAddress: mintAddress).toBlocking().first()
        XCTAssertNotNil(account)
    }
}
