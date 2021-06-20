import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class getTokenWallets: XCTestCase {
    var endpoint = RPCEndpoint.testnetSolana
    var solanaSDK: Solana!
    var account: Account { try! solanaSDK.auth.account.get() }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .getWallets
        solanaSDK = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solanaSDK.auth.save(account).get()
    }
    
    func testsGetTokenWallets() {
        let wallets = try! solanaSDK.getTokenWallets().toBlocking().first()
        XCTAssertNotNil(wallets)
    }
}
