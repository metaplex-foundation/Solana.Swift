import XCTest
import RxSwift
import RxBlocking
@testable import RxSolana
import Solana

class createTokenAccount: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solanaSDK: Solana!
    var account: Account { try! solanaSDK.auth.account.get() }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solanaSDK.auth.save(account).get()
    }
    
    func testCreateTokenAccount() {
        let mintAddress = "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH"
        let account = try! solanaSDK.createTokenAccount( mintAddress: mintAddress).toBlocking().first()
        XCTAssertNotNil(account)
    }
    
    func testCreateAccountInstruction() {
        let instruction = SystemProgram.createAccountInstruction(from: PublicKey.programId, toNewPubkey: PublicKey.programId, lamports: 2039280, space: 165, programPubkey: PublicKey.programId)
        
        XCTAssertEqual("11119os1e9qSs2u7TsThXqkBSRUo9x7kpbdqtNNbTeaxHGPdWbvoHsks9hpp6mb2ed1NeB", Base58.encode(instruction.data))
    }
}
