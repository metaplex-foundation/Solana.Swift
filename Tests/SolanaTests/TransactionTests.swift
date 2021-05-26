//
//  TransactionTests.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import XCTest
@testable import Solana
import CryptoSwift

class TransactionTests: XCTestCase {
    func testCreatingTransfer() throws {
        let compiled = [UInt8]([2, 2, 0, 1, 12, 2, 0, 0, 0, 184, 11, 0, 0, 0, 0, 0, 0])
        var receiver = [UInt8]()
        let data = Solana.Transfer.compile()
        receiver.append(contentsOf: data)
        XCTAssertEqual(compiled, receiver)
    }

//    func testSerializeMessage() throws {
//        let fromPublicKey = try SolanaSDK.PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
//        let toPublicKey = try SolanaSDK.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
//        let lamports: UInt64 = 3000
//        
//        var message = SolanaSDK.ConfirmedTransaction.Message()
//        message.add(instruction: SolanaSDK.SystemProgram.transferInstruction(from: fromPublicKey, to: toPublicKey, lamports: lamports))
//        message.recentBlockhash = "Eit7RCyhUixAe2hGBS8oqnw59QK3kgMMjfLME5bm9wRn"
//        
//        XCTAssertEqual([1, 0, 1, 3, 6, 26, 217, 208, 83, 135, 21, 72, 83, 126, 222, 62, 38, 24, 73, 163, 223, 183, 253, 2, 250, 188, 117, 178, 35, 200, 228, 106, 219, 133, 61, 12, 235, 122, 188, 208, 216, 117, 235, 194, 109, 161, 177, 129, 163, 51, 155, 62, 242, 163, 22, 149, 187, 122, 189, 188, 103, 130, 115, 188, 173, 205, 229, 170, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 203, 226, 136, 193, 153, 148, 240, 50, 230, 98, 9, 79, 221, 179, 243, 174, 90, 67, 104, 169, 6, 187, 165, 72, 36, 156, 19, 57, 132, 38, 69, 245, 1, 2, 2, 0, 1, 12, 2, 0, 0, 0, 184, 11, 0, 0, 0, 0, 0, 0], try message.serialize())
//    }
//    
//    func testSignAndSerializeTransfer() throws {
//        let fromPublicKey = try SolanaSDK.PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
//        let toPublicKey = try SolanaSDK.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
//        let lamports: UInt64 = 3000
//        
//        let signer = try SolanaSDK.Account(secretKey: Data(Base58.decode("4Z7cXSyeFR8wNGMVXUE1TwtKn5D5Vu7FzEv69dokLv7KrQk7h6pu4LF8ZRR9yQBhc7uSM6RTTZtU1fmaxiNrxXrs")))
//        
//        var transaction = SolanaSDK.ConfirmedTransaction()
//        transaction.add(instruction: SolanaSDK.SystemProgram.transferInstruction(from: fromPublicKey, to: toPublicKey, lamports: lamports))
//        transaction.set(recentBlockhash: "Eit7RCyhUixAe2hGBS8oqnw59QK3kgMMjfLME5bm9wRn")
//        try transaction.sign(signers: [signer])
//        let serializedTransaction = try transaction.serialize().toBase64()!
//        
//        XCTAssertEqual("ASdDdWBaKXVRA+6flVFiZokic9gK0+r1JWgwGg/GJAkLSreYrGF4rbTCXNJvyut6K6hupJtm72GztLbWNmRF1Q4BAAEDBhrZ0FOHFUhTft4+JhhJo9+3/QL6vHWyI8jkatuFPQzrerzQ2HXrwm2hsYGjM5s+8qMWlbt6vbxngnO8rc3lqgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAy+KIwZmU8DLmYglP3bPzrlpDaKkGu6VIJJwTOYQmRfUBAgIAAQwCAAAAuAsAAAAAAAA=", serializedTransaction)
//    }

}
