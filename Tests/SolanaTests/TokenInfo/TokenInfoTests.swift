import Foundation
import XCTest
@testable import Solana

class TokenInfoTests: XCTestCase {
    var endpoint = RPCEndpoint.mainnetBetaSolana
    var solanaSDK: Solana!

    override func setUpWithError() throws {
        let tokenProvider = try! TokenListProvider(path: getFileFrom("TokenInfo/mainnet-beta.tokens"))
        solanaSDK = Solana(router: NetworkingRouter(endpoint: endpoint), tokenProvider: tokenProvider)
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

