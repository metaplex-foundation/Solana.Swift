import Foundation
import XCTest
@testable import Solana

class TokenInfoTests: XCTestCase {
    var endpoint = RPCEndpoint.mainnetBetaSolana
    var solanaSDK: Solana!
    var account: Account { try! solanaSDK.auth.account.get() }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage(), tokenProvider: ListTokenInfoProvider(endpoint: endpoint))
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solanaSDK.auth.save(account).get()
    }
    
    func testCloseAccountInstruction() {
        XCTAssertEqual(solanaSDK.tokens.supportedTokens.count, 396)
    }
}
