import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class getTokenWallets: XCTestCase {
    var endpoint = Solana.RpcApiEndPoint.devnetSolana
    var solanaSDK: Solana!
    var account: Solana.Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = try Solana.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        try solanaSDK.accountStorage.save(account)
    }
    
    func testsGetTokenWallets() throws {
        let wallets = try solanaSDK.getTokenWallets().toBlocking().first()
        XCTAssertNotNil(wallets)
    }
}
