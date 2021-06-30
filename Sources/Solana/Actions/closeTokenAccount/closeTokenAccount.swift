import Foundation

extension Action {
    public func closeTokenAccount(
        account: Account,
        tokenPubkey: PublicKey,
        onComplete: @escaping (Result<TransactionID, Error>) -> Void
    ) {
        let instruction = TokenProgram.closeAccountInstruction(
            account: tokenPubkey,
            destination: account.publicKey,
            owner: account.publicKey
        )
        serializeAndSendWithFee(instructions: [instruction], signers: [account]) {
            onComplete($0)
            return
        }
    }
}
