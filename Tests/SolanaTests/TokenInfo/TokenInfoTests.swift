import Foundation
import XCTest
@testable import Solana

class TokenInfoTests: XCTestCase {
    var endpoint = RPCEndpoint.mainnetBetaSolana
    var solanaSDK: Solana!
    var account: Account!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(router: NetworkingRouter(endpoint: endpoint), tokenProvider: ListTokenInfoProvider(endpoint: endpoint))
        account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
    }
    
    func testCloseAccountInstruction() {
        XCTAssertEqual(solanaSDK.tokens.supportedTokens.count, 396)
    }
}
