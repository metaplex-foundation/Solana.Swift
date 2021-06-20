import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class getTokenWallets: XCTestCase {
    var endpoint = RPCEndpoint.testnetSolana
    var solana: Solana!
    var account: Account { try! solana.auth.account.get() }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .getWallets
        solana = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solana.auth.save(account).get()
    }
    
    func testsGetTokenWallets() {
        let wallets = try! solana.action.getTokenWallets().toBlocking().first()
        XCTAssertNotNil(wallets)
    }
}
