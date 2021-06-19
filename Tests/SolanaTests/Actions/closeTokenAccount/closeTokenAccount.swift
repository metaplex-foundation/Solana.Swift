import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class closeTokenAccount: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solanaSDK: Solana!
    var account: Solana.Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Solana.Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solanaSDK.accountStorage.save(account).get()
    }
    
    func testCloseAccountInstruction() {
        let publicKey = Solana.PublicKey(string: "11111111111111111111111111111111")!
        let instruction = Solana.TokenProgram.closeAccountInstruction(tokenProgramId: publicKey, account: publicKey, destination: publicKey, owner: publicKey)
        XCTAssertEqual("A", Base58.encode(instruction.data))
    }
}
