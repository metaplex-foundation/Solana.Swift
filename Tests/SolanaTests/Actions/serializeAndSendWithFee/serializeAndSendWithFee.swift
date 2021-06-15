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
    func testSendSOLFromBalance() throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try solanaSDK.getBalance().toBlocking().first()
        XCTAssertNotNil(balance)

        let transactionId = try solanaSDK.sendSOL(
            to: toPublicKey,
            amount: balance!/10
        ).toBlocking().first()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOL() throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        let transactionId = try solanaSDK.sendSOL(
            to: toPublicKey,
            amount: 0.001.toLamport(decimals: 9)
        ).toBlocking().first()
        XCTAssertNotNil(transactionId)
    }
}
