import Foundation
import XCTest
@testable import Solana

class TokenInfoTests: XCTestCase {
    var endpoint = RPCEndpoint.mainnetBetaSolana
    var solanaSDK: Solana!
    var account: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        let tokenProvider = try! TokenListProvider(path: getFileFrom("TokenInfo/mainnet-beta.tokens"))
        solanaSDK = Solana(router: NetworkingRouter(endpoint: endpoint), tokenProvider: tokenProvider)
        account = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
    }
    
    func testCloseAccountInstruction() {
        XCTAssert(solanaSDK.tokens.supportedTokens.count > 1000)
    }
}

func getFileFrom(_ filename: String) -> URL {
    @objc class SolanaTests: NSObject { }
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    let resourceURL = thisDirectory.appendingPathComponent("../Resources/\(filename).json")
    return resourceURL
}

