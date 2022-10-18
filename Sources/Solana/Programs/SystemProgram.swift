import Foundation
import Beet

public struct SystemProgram {
    private struct Index {
        static let create: UInt32 = 0
        static let transfer: UInt32 = 2
    }

    public static func createAccountInstruction(
        from fromPublicKey: PublicKey,
        toNewPubkey newPubkey: PublicKey,
        lamports: UInt64,
        space: UInt64 = AccountInfo.BUFFER_LENGTH,
        programPubkey: PublicKey = PublicKey.tokenProgramId
    ) -> TransactionInstruction {

        TransactionInstruction(
            keys: [
                AccountMeta(publicKey: fromPublicKey, isSigner: true, isWritable: true),
                AccountMeta(publicKey: newPubkey, isSigner: true, isWritable: true)
            ],
            programId: PublicKey.systemProgramId,
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
                AccountMeta(publicKey: fromPublicKey, isSigner: true, isWritable: true),
                AccountMeta(publicKey: toPublicKey, isSigner: false, isWritable: true)
            ],
            programId: PublicKey.systemProgramId,
            data: [Index.transfer, lamports]
        )
    }

    public static func assertOwnerInstruction(
        destinationAccount: PublicKey
    ) -> TransactionInstruction {
        TransactionInstruction(
            keys: [
                AccountMeta(publicKey: destinationAccount, isSigner: false, isWritable: false)
            ],
            programId: .ownerValidationProgramId,
            data: [PublicKey.systemProgramId]
        )
    }
}
