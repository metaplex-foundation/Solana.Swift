//
//  SystemProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 25/01/2021.
//

import Foundation

public extension Solana {
    struct SystemProgram {
        private struct Index {
            static let create: UInt32 = 0
            static let transfer: UInt32 = 2
        }

        public static func createAccountInstruction(
            from fromPublicKey: PublicKey,
            toNewPubkey newPubkey: PublicKey,
            lamports: UInt64,
            space: UInt64 = AccountInfo.span,
            programPubkey: PublicKey = PublicKey.tokenProgramId
        ) -> TransactionInstruction {

            TransactionInstruction(
                keys: [
                    Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true),
                    Account.Meta(publicKey: newPubkey, isSigner: true, isWritable: true)
                ],
                programId: PublicKey.programId,
                data: [Index.create, lamports, space, programPubkey]
            )
        }

        public static func transferInstruction(
            from fromPublicKey: PublicKey,
            to toPublicKey: PublicKey,
            lamports: UInt64
        ) -> TransactionInstruction {

            TransactionInstruction(
                keys: [
                    Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true),
                    Account.Meta(publicKey: toPublicKey, isSigner: false, isWritable: true)
                ],
                programId: PublicKey.programId,
                data: [Index.transfer, lamports]
            )
        }

        public static func assertOwnerInstruction(
            destinationAccount: PublicKey
        ) -> TransactionInstruction {
            TransactionInstruction(
                keys: [
                    Account.Meta(publicKey: destinationAccount, isSigner: false, isWritable: false)
                ],
                programId: .ownerValidationProgramId,
                data: [PublicKey.programId]
            )
        }
    }
}
