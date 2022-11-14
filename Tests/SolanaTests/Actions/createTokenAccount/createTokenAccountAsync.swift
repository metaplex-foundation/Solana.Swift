import XCTest
import Solana

@available(iOS 13.0, *)
@available(macOS 10.15, *)
class createTokenAccountAsync: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var networkRouterMock: NetworkingRouterMock!
    var solana: Solana!
    var account: Signer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let wallet: TestsWallet = .devnet
        networkRouterMock = NetworkingRouterMock()
        solana = Solana(router: networkRouterMock)
        account = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
    }
    
    func testCreateTokenAccount() async throws {
        // arrange
        let mintAddress = "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH"
        networkRouterMock.expectedResults.append(contentsOf: [
            .success(.json(filename: "getRecentBlockhash")),
            .success(.json(filename: "getMinimumBalanceForRentExemption")),
            .success(.json(filename: "sendTransaction"))
        ])

        // act
        let account: (signature: String, newPubkey: String)? = try! await solana.action.createTokenAccount( mintAddress: mintAddress, payer: self.account)
        
        // assert
        XCTAssertEqual(networkRouterMock.requestCalled.count, 3)
        XCTAssertEqual(account?.signature,
                       "TWui8GhF8vp8BtiGXhvxgti7LJGpVu7hx4tXzi3pqSycipNbJokDcFayw8a9YdcKJ789fSRjU6CRwPJ2zNp52eB")
        XCTAssertNotNil(account?.newPubkey)
    }
    
    func testCreateAccountInstruction() {
        let instruction = SystemProgram.createAccountInstruction(from: PublicKey.systemProgramId, toNewPubkey: PublicKey.systemProgramId, lamports: 2039280, space: 165, programPubkey: PublicKey.systemProgramId)
        
        XCTAssertEqual("11119os1e9qSs2u7TsThXqkBSRUo9x7kpbdqtNNbTeaxHGPdWbvoHsks9hpp6mb2ed1NeB", Base58.encode(instruction.data))
    }
}
