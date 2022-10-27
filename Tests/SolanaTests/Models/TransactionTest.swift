//
//  TransactionTest.swift
//  
//
//  Created by Mirek Rousal on 25/10/2022.
//

import Foundation
import XCTest

@testable import Solana

@available(iOS 13.0.0, *)
final class TransactionTest: XCTestCase {
    
    func testCompiledMessageAccountKeysAreOrdered() async throws {
        // These pubkeys are chosen specially to be in sort order.
        let payer = PublicKey(string:
            "3qMLYYyNvaxNZP7nW8u5abHMoJthYqQehRLbFVPNNcvQ"
        )!
        let accountWritableSigner2 = PublicKey(string:
            "3XLtLo5Z4DG8b6PteJidF6kFPNDfxWjxv4vTLrjaHTvd"
        )!
        let accountWritableSigner3 = PublicKey(string:
            "4rvqGPb4sXgyUKQcvmPxnWEZTTiTqNUZ2jjnw7atKVxa"
        )!
        let accountSigner4 = PublicKey(string:
            "5oGjWjyoKDoXGpboGBfqm9a5ZscyAjRi3xuGYYu1ayQg"
        )!
        let accountSigner5 = PublicKey(string:
            "65Rkc3VmDEV6zTRGtgdwkTcQUxDJnJszj2s4WoXazYpC"
        )!
        let accountWritable6 = PublicKey(string:
            "72BxBZ9eD9Ue6zoJ9bzfit7MuaDAnq1qhirgAoFUXz9q"
        )!
        let accountWritable7 = PublicKey(string:
            "BtYrPUeVphVgRHJkf2bKz8DLRxJdQmZyANrTM12xFqZL"
        )!
        let accountRegular8 = PublicKey(string:
            "Di1MbqFwpodKzNrkjGaUHhXC4TJ1SHUAxo9agPZphNH1"
        )!
        let accountRegular9 = PublicKey(string:
            "DYzzsfHTgaNhCgn7wMaciAYuwYsGqtVNg9PeFZhH93Pc"
        )!
        let programId = PublicKey(string:
            "Fx9svCTdxnACvmEmx672v2kP1or4G1zC73tH7XsXbKkP"
        )!

        let recentBlockhash = HotAccount()!.publicKey.base58EncodedString
        
        let accountMetas: [AccountMeta] = [
            // Regular accounts
            AccountMeta(publicKey: accountRegular9, isSigner: false, isWritable: false),
            AccountMeta(publicKey: accountRegular8, isSigner: false, isWritable: false),
            // Writable accounts
            AccountMeta(publicKey: accountWritable7, isSigner: false, isWritable: true),
            AccountMeta(publicKey: accountWritable6, isSigner: false, isWritable: true),
            // Signers
            AccountMeta(publicKey: accountSigner5, isSigner: true, isWritable: false),
            AccountMeta(publicKey: accountSigner4, isSigner: true, isWritable: false),
            // Writable Signers
            AccountMeta(publicKey: accountWritableSigner3, isSigner: true, isWritable: true),
            AccountMeta(publicKey: accountWritableSigner2, isSigner: true, isWritable: true),
            // Payer
            AccountMeta(publicKey: payer, isSigner: true, isWritable: true),
        ]
        
        let transactionIntruction = TransactionInstruction(keys: accountMetas, programId: programId, data: [])
        let transaction = Transaction(feePayer: payer, instructions: [transactionIntruction], recentBlockhash: recentBlockhash)
        
        let message = try transaction.compileMessage().get()
        
        // Payer comes first.
        XCTAssertEqual(message.accountKeys[0].publicKey, payer)

        // Writable signers come next, in pubkey order.
        XCTAssertEqual(message.accountKeys[1].publicKey, accountWritableSigner2)
        XCTAssertEqual(message.accountKeys[2].publicKey, accountWritableSigner3)

        // Signers come next, in pubkey order.
        XCTAssertEqual(message.accountKeys[3].publicKey, accountSigner4)
        XCTAssertEqual(message.accountKeys[4].publicKey, accountSigner5)

        // Writable accounts come next, in pubkey order.
        XCTAssertEqual(message.accountKeys[5].publicKey, accountWritable6)
        XCTAssertEqual(message.accountKeys[6].publicKey, accountWritable7)

        // Everything else afterward, in pubkey order.
        XCTAssertEqual(message.accountKeys[7].publicKey, accountRegular8)
        XCTAssertEqual(message.accountKeys[8].publicKey, accountRegular9)
        XCTAssertEqual(message.accountKeys[9].publicKey, programId)
    }
    
    func testAccountKeysCollapsesSignednessAndWritebility() async throws {
        // These pubkeys are chosen specially to be in sort order.
        let payer = PublicKey(string:
            "2eBgaMN8dCnCjx8B8Wrwk974v5WHwA6Vvj4N2mW9KDyt"
        )!
        let account2 = PublicKey(
            string: "DL8FErokCN7rerLdmJ7tQvsL1FsqDu1sTKLLooWmChiW"
        )!
        let account3 = PublicKey(
            string: "EdPiTYbXFxNrn1vqD7ZdDyauRKG4hMR6wY54RU1YFP2e"
        )!
        let account4 = PublicKey(
            string: "FThXbyKK4kYJBngSSuvo9e6kc7mwPHEgw4V8qdmz1h3k"
        )!
        let programId = PublicKey(
            string: "Gcatgv533efD1z2knsH9UKtkrjRWCZGi12f8MjNaDzmN"
        )!
        let account5 = PublicKey(
            string: "rBtwG4bx85Exjr9cgoupvP1c7VTe7u5B36rzCg1HYgi"
        )!

        let recentBlockhash = HotAccount()!.publicKey.base58EncodedString
        
        let accountMetas: [AccountMeta] = [
            // Should sort last.
            AccountMeta(publicKey: account5, isSigner: false, isWritable: false),
            AccountMeta(publicKey: account5, isSigner: false, isWritable: false),
            // Should be considered writeable.
            AccountMeta(publicKey: account4, isSigner: false, isWritable: true),
            AccountMeta(publicKey: account4, isSigner: false, isWritable: true),
            // Should be considered a signer.
            AccountMeta(publicKey: account3, isSigner: true, isWritable: false),
            AccountMeta(publicKey: account3, isSigner: true, isWritable: false),
            // Should be considered a writable signer.
            AccountMeta(publicKey: account2, isSigner: true, isWritable: true),
            AccountMeta(publicKey: account2, isSigner: true, isWritable: true),
            // Payer
            AccountMeta(publicKey: payer, isSigner: true, isWritable: true),
        ]
        
        let transactionIntruction = TransactionInstruction(keys: accountMetas, programId: programId, data: [])
        let transaction = Transaction(feePayer: payer, instructions: [transactionIntruction], recentBlockhash: recentBlockhash)
        
        let message = try transaction.compileMessage().get()

        // Payer comes first.
        XCTAssertEqual(message.accountKeys[0].publicKey, payer)

        // Writable signer comes first.
        XCTAssertEqual(message.accountKeys[1].publicKey, account2)

        // Signer comes next.
        XCTAssertEqual(message.accountKeys[2].publicKey, account3)

        // Writable account comes next.
        XCTAssertEqual(message.accountKeys[3].publicKey, account4)

        // Regular accounts come last.
        XCTAssertEqual(message.accountKeys[4].publicKey, programId)
        XCTAssertEqual(message.accountKeys[5].publicKey, account5)
    }
    
    func testParseTransaction() async throws {
        let base64EncodedTransaction = "AowfOvMIGMKpHdSMkJngzXiF+R1nhZpXl4ead8v9j2KMRNGWxw4ORAEMBxVDHauoPybbYzxE8DxwVkGNSlpHJA8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAGDE1NcOheAvyv+bxRcoAAg+MRGtu2bkAm/5wdXQJ8rken1FULStGZ1asG/Yq4nf1D5fRiPugrD4fCDubSMsuHkdIayMAB688AuwbzoF9XnkQFo2FzCNJXzqL54DE6mJ3jcVhQyOsVuOXyU8XVGmOO2ep3vzbZGM4vgpLvjEcAM00J+V3TgVRf23jeOe/lnzkzO6KxIRRsdiBzWWuNQTu8yH/6ZEwlvNmeorQ162ZCz63Oge4CfDiNpiav1AqEyomoh3Fva1OSac1YjEGTGcfA31cfJcQU3+q9HrQZS+lxomSRdvMm5PB133e9DwijLEt6TSX1hyKy/MHeJpT5sgfx0Q6rTKN/L2kwSCbxyvNbI19PNeLYInltDmx6X1AtAMntzsjbHnHIO/C4BzQArccr6sxzJRGosQj9TDQA5uKlJYJ+C3BlsePRfEU4nVJ/awTDzVi4bHMaoP21SbbRvAP4KUYG3fbh12Whk9nL4UbO63msHLSF7V9bN5E6jPWFfv8AqS9th6tOQZlmjaIuFlZG82nyqa3jkyOF4l/umJZJMUYrAQcMAwQFAgABBggJCwsKQgxhNeMOztloLAAAAHE5N3A1TzE3VXRqWUVwRWI4UVd0Y0tXTi9hK0Q4MjI0OFhwOEdDNEFSczg9BgAAADEyMzQ1Ng=="
        
        let decoded = Data(base64Encoded: base64EncodedTransaction)!
        
        var transaction = try Transaction.from(buffer: decoded)
        
        let message = try transaction.compileMessage().get()
        
        // Payer comes first.
        XCTAssertEqual(message.accountKeys[0].publicKey, PublicKey(string: "6Ckt9z51g3ubcBSMN4LCEGQUx6uPXT8FDVSkcfXnPs3k"))

        XCTAssertEqual(message.accountKeys[1].publicKey, PublicKey(string: "FHreS1zRRqDKYfkZzoCKCPyxPNqwFFCky15qWpcvZJTT"))
        XCTAssertEqual(message.accountKeys[2].publicKey, PublicKey(string: "2oZ9P3qQXm9B7iG5rGzbaA6QNeYDBypxWHEQd3D77z1W"))

        XCTAssertEqual(message.accountKeys[3].publicKey, PublicKey(string: "6wkKngADM4ZrU7btDg4vohhsCjF75NQVsnRwwas4uZfW"))
        XCTAssertEqual(message.accountKeys[4].publicKey, PublicKey(string: "HnRVqFfui3G99GKZbcpyRRP2y44nwwFD124xdGnWFjjt"))

        XCTAssertEqual(message.accountKeys[5].publicKey, PublicKey(string: "HrRdRe81iMRne9NRy5cJosW7JBMkxUi9fof1cTZxudXU"))
        XCTAssertEqual(message.accountKeys[6].publicKey, PublicKey(string: "8docMfZQX4wbEfqDUtL2tiKjZDQhsAB7ZjXneBD71SUG"))

        XCTAssertEqual(message.accountKeys[7].publicKey, PublicKey(string: "91L9t9gwA2o75PUx9RYc9BUm4XYWjDhs3fj55ajvNvoP"))
        XCTAssertEqual(message.accountKeys[8].publicKey, PublicKey(string: "CXgVmL5q9QUJAkdRyi5boRqPKZzpsYNoU6FMPM2SrJ3X"))
        XCTAssertEqual(message.accountKeys[9].publicKey, PublicKey(string: "EX4L7EXoA1BH6fRCqa8SLPuPrnY7nSxFgF6jgsa7i4Mb"))
                
        transaction.serialize(requiredAllSignatures: false, verifySignatures: true)
            .onFailure {
                print($0.localizedDescription)
            }
            .onSuccess {
                let base64 = $0.base64EncodedString()
                XCTAssertEqual(base64, base64EncodedTransaction)
            }
    
    }
}

