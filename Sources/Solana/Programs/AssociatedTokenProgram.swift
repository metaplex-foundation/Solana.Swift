import Foundation

public struct AssociatedTokenProgram {
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
