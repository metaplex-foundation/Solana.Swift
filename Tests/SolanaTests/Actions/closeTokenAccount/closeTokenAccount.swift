import XCTest
@testable import Solana

class closeTokenAccount: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solanaSDK: Solana!
    var account: Account { try! solanaSDK.auth.account.get() }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solanaSDK.auth.save(account).get()
    }
    
    func testCloseAccountInstruction() {
        let publicKey = PublicKey(string: "11111111111111111111111111111111")!
        let instruction = TokenProgram.closeAccountInstruction(tokenProgramId: publicKey, account: publicKey, destination: publicKey, owner: publicKey)
        XCTAssertEqual("A", Base58.encode(instruction.data))
    }
}
