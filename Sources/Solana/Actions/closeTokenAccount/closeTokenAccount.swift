import Foundation

extension Solana {
    public func closeTokenAccount(
        account: Solana.Account? = nil,
        tokenPubkey: String,
        onComplete: @escaping (Result<TransactionID, Error>) -> ()
    ) {
        guard let account = account ?? accountStorage.account else {
            onComplete(.failure(SolanaError.unauthorized))
            return
        }
        do {
            let tokenPubkey = try PublicKey(string: tokenPubkey)
            
            let instruction = TokenProgram.closeAccountInstruction(
                account: tokenPubkey,
                destination: account.publicKey,
                owner: account.publicKey
            )
            serializeAndSendWithFee(instructions: [instruction], signers: [account]){
                onComplete($0)
                return
            }
        } catch {
            onComplete(.failure((error)))
            return
        }
    }
}
