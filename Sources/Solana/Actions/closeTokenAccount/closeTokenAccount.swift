import Foundation

extension Solana {
    public func closeTokenAccount(
        account: Account? = nil,
        tokenPubkey: String,
        onComplete: @escaping (Result<TransactionID, Error>) -> Void
    ) {
        guard let account = account ?? accountStorage.account else {
            onComplete(.failure(SolanaError.unauthorized))
            return
        }
        guard let tokenPubkey = PublicKey(string: tokenPubkey) else {
            onComplete(.failure(SolanaError.invalidPublicKey))
            return
        }

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
