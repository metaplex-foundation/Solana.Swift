import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class serializeAndSendWithFee: XCTestCase {
    var endpoint = Solana.RpcApiEndPoint.devnetSolana
    var solanaSDK: Solana!
    var account: Solana.Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        let account = try Solana.Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)
        try solanaSDK.accountStorage.save(account)
    }

    func testSimulationSerializeAndSend() throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try solanaSDK.getBalance().toBlocking().first()
        XCTAssertNotNil(balance)

        let instruction = Solana.SystemProgram.transferInstruction(
            from: account.publicKey,
            to: try Solana.PublicKey(string: toPublicKey),
            lamports: 0.001.toLamport(decimals: 9)
        )
        
        let transactionId = try solanaSDK.serializeAndSendWithFeeSimulation(instructions: [instruction], signers: [account]).toBlocking().first()
        XCTAssertNotNil(transactionId)
    }
    
    func testSerializeAndSend() throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try solanaSDK.getBalance().toBlocking().first()
        XCTAssertNotNil(balance)

        let instruction = Solana.SystemProgram.transferInstruction(
            from: account.publicKey,
            to: try Solana.PublicKey(string: toPublicKey),
            lamports: 0.001.toLamport(decimals: 9)
        )
        
        let transactionId = try solanaSDK.serializeAndSendWithFee( instructions: [instruction], signers: [account]).toBlocking().first()
        XCTAssertNotNil(transactionId)
    }
    
    func testTransferInstruction() throws {
        let fromPublicKey = try Solana.PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
        let toPublicKey = try Solana.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
        
        let instruction = Solana.SystemProgram.transferInstruction(from: fromPublicKey, to: toPublicKey, lamports: 3000)
        
        XCTAssertEqual(Solana.PublicKey.programId, instruction.programId)
        XCTAssertEqual(2, instruction.keys.count)
        XCTAssertEqual(toPublicKey, instruction.keys[1].publicKey)
        XCTAssertEqual([2, 0, 0, 0, 184, 11, 0, 0, 0, 0, 0, 0], instruction.data)
    }
    
    func testInitializeAccountInstruction() throws {
        let publicKey = try! Solana.PublicKey(string: "11111111111111111111111111111111")
        let instruction = Solana.TokenProgram.initializeAccountInstruction(account: publicKey, mint: publicKey, owner: publicKey)
        XCTAssertEqual("2", Base58.encode(instruction.data))
    }
    
    func testApproveInstruction() throws {
        let publicKey = try! Solana.PublicKey(string: "11111111111111111111111111111111")
        let instruction = Solana.TokenProgram.approveInstruction(tokenProgramId: publicKey, account: publicKey, delegate: publicKey, owner: publicKey, amount: 1000)
        XCTAssertEqual("4d5tSvUuzUVM", Base58.encode(instruction.data))
    }
}
