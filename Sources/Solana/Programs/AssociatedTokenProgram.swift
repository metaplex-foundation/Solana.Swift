//
//  AssociatedTokenProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 27/04/2021.
//

import Foundation
import TweetNacl

extension Solana {
    struct AssociatedTokenProgram {
        // MARK: - Interface
        static func createAssociatedTokenAccountInstruction(
            associatedProgramId: PublicKey = .splAssociatedTokenAccountProgramId,
            programId: PublicKey = .tokenProgramId,
            mint: PublicKey,
            associatedAccount: PublicKey,
            owner: PublicKey,
            payer: PublicKey
        ) -> TransactionInstruction {
            TransactionInstruction(
                keys: [
                    .init(publicKey: payer, isSigner: true, isWritable: true),
                    .init(publicKey: associatedAccount, isSigner: false, isWritable: true),
                    .init(publicKey: owner, isSigner: false, isWritable: false),
                    .init(publicKey: mint, isSigner: false, isWritable: false),
                    .init(publicKey: .programId, isSigner: false, isWritable: false),
                    .init(publicKey: programId, isSigner: false, isWritable: false),
                    .init(publicKey: .sysvarRent, isSigner: false, isWritable: false)
                ],
                programId: associatedProgramId,
                data: []
            )
        }
    }
}
