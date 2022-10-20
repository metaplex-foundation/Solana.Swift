import XCTest
@testable import Solana

@available(iOS 13.0, *)
@available(macOS 10.15, *)
class serializeAndSendWithFeeAsync: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solana: Solana!
    var account: Account!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solana = Solana(router: NetworkingRouter(endpoint: endpoint))
        account = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
    }

    func testSimulationSerializeAndSend() async throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try await solana.api.getBalance(account: account.publicKey.base58EncodedString)
        XCTAssertNotNil(balance)

        let instruction = SystemProgram.transferInstruction(
            from: account.publicKey,
            to: PublicKey(string: toPublicKey)!,
            lamports: 0.001.toLamport(decimals: 9)
        )
        
        let transactionId = try await solana.action.serializeAndSendWithFeeSimulation(instructions: [instruction], signers: [account])
        XCTAssertNotNil(transactionId)
    }
    
    func testSerializeAndSend() async throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try await solana.api.getBalance(account: account.publicKey.base58EncodedString)
        XCTAssertNotNil(balance)

        let instruction = SystemProgram.transferInstruction(
            from: account.publicKey,
            to: PublicKey(string: toPublicKey)!,
            lamports: 0.001.toLamport(decimals: 9)
        )
        
        let transactionId = try await solana.action.serializeAndSendWithFee( instructions: [instruction], signers: [account])
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
