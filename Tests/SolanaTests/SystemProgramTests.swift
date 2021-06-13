import XCTest
@testable import Solana

class SystemProgramTests: XCTestCase {
    func testTransferInstruction() throws {
        let fromPublicKey = try Solana.PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
        let toPublicKey = try Solana.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
        
        let instruction = Solana.SystemProgram.transferInstruction(from: fromPublicKey, to: toPublicKey, lamports: 3000)
        
        XCTAssertEqual(Solana.PublicKey.programId, instruction.programId)
        XCTAssertEqual(2, instruction.keys.count)
        XCTAssertEqual(toPublicKey, instruction.keys[1].publicKey)
        XCTAssertEqual([2, 0, 0, 0, 184, 11, 0, 0, 0, 0, 0, 0], instruction.data)
    }
    
    func testCreateAccountInstruction() throws {
        let instruction = Solana.SystemProgram.createAccountInstruction(from: Solana.PublicKey.programId, toNewPubkey: Solana.PublicKey.programId, lamports: 2039280, space: 165, programPubkey: Solana.PublicKey.programId)
        
        XCTAssertEqual("11119os1e9qSs2u7TsThXqkBSRUo9x7kpbdqtNNbTeaxHGPdWbvoHsks9hpp6mb2ed1NeB", Base58.encode(instruction.data))
    }
}
