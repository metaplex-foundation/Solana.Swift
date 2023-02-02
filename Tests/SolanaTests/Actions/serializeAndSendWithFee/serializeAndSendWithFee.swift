import XCTest
@testable import Solana

class serializeAndSendWithFee: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var signer: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = Solana(router: NetworkingRouter(endpoint: endpoint))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
    }

    func testSimulationSerializeAndSend() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try! solana.api.getBalance(account: signer.publicKey.base58EncodedString)?.get()
        XCTAssertNotNil(balance)

        let instruction = SystemProgram.transferInstruction(
            from: signer.publicKey,
            to: PublicKey(string: toPublicKey)!,
            lamports: 0.001.toLamport(decimals: 9)
        )
        
        let transactionId = try! solana.action.serializeAndSendWithFeeSimulation(instructions: [instruction], signers: [signer])?.get()
        XCTAssertNotNil(transactionId)
    }
    
    func testSerializeAndSend() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try! solana.api.getBalance(account: signer.publicKey.base58EncodedString)?.get()
        XCTAssertNotNil(balance)

        let instruction = SystemProgram.transferInstruction(
            from: signer.publicKey,
            to: PublicKey(string: toPublicKey)!,
            lamports: 0.001.toLamport(decimals: 9)
        )
        
        let transactionId = try! solana.action.serializeAndSendWithFee( instructions: [instruction], signers: [signer])?.get()
        XCTAssertNotNil(transactionId)
    }
    
    func testTransferInstruction() {
        let fromPublicKey = PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")!
        let toPublicKey = PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")!
        
        let instruction = SystemProgram.transferInstruction(from: fromPublicKey, to: toPublicKey, lamports: 3000)
        
        XCTAssertEqual(PublicKey.systemProgramId, instruction.programId)
        XCTAssertEqual(2, instruction.keys.count)
        XCTAssertEqual(toPublicKey, instruction.keys[1].publicKey)
        XCTAssertEqual([2, 0, 0, 0, 184, 11, 0, 0, 0, 0, 0, 0], instruction.data)
    }
    
    func testInitializeAccountInstruction() {
        let publicKey = PublicKey(string: "11111111111111111111111111111111")!
        let instruction = TokenProgram.initializeAccountInstruction(account: publicKey, mint: publicKey, owner: publicKey)
        XCTAssertEqual("2", Base58.encode(instruction.data))
    }
    
    func testApproveInstruction() {
        let publicKey = PublicKey(string: "11111111111111111111111111111111")!
        let instruction = TokenProgram.approveInstruction(tokenProgramId: publicKey, account: publicKey, delegate: publicKey, owner: publicKey, amount: 1000)
        XCTAssertEqual("4d5tSvUuzUVM", Base58.encode(instruction.data))
    }
}
