import XCTest
import Solana

@available(iOS 13.0, *)
@available(macOS 10.15, *)
class getTokenWalletsAsync: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var account: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .getWallets
        solana = Solana(router: NetworkingRouter(endpoint: endpoint))
        account = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
    }
    
    func testsGetTokenWallets() async throws {
        let wallets = try await solana.action.getTokenWallets(account: account.publicKey.base58EncodedString)
        XCTAssertFalse(wallets.isEmpty)
    }
}
