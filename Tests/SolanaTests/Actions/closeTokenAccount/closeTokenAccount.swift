import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class closeTokenAccount: XCTestCase {
    var endpoint = Solana.RpcApiEndPoint.devnetSolana
    var solanaSDK: Solana!
    var account: Solana.Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = try Solana.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        try solanaSDK.accountStorage.save(account)
    }
    
    /*func testCloseAccount() throws {
        let token = "31VJdomzjjKRyezbyBW2Ktf585T7XgWRGPyfoc7B1Q6F"
        _ = try solanaSDK.closeTokenAccount(
            tokenPubkey: token
        ).toBlocking().first()
    }*/
}
