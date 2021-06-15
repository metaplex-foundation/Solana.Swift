import Foundation

extension Solana {
    internal func serializeTransaction(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        feePayer: PublicKey? = nil,
        onComplete: @escaping ((Result<String, Error>) -> ())
    ){
        
        guard let feePayer = feePayer ?? accountStorage.account?.publicKey else {
            onComplete(.failure(SolanaError.invalidRequest(reason: "Fee-payer not found")))
            return
        }
        
        let getRecentBlockhashRequest: (Result<String, Error>)->() = { result in
            switch result {
            case .success(let recentBlockhash):
                var transaction = Transaction(
                    feePayer: feePayer,
                    instructions: instructions,
                    recentBlockhash: recentBlockhash
                )
                do {
                    try transaction.sign(signers: signers)
                    guard let serializedTransaction = try transaction.serialize().bytes.toBase64() else {
                        onComplete(.failure(SolanaError.other("Could not serialize transaction")))
                        return
                    }
                    onComplete(.success(serializedTransaction))
                    return
                } catch let signingError{
                    onComplete(.failure(signingError))
                    return
                }
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }
        
        if let recentBlockhash = recentBlockhash {
            getRecentBlockhashRequest(.success(recentBlockhash))
        } else {
            getRecentBlockhash() { getRecentBlockhashRequest($0) }
        }
    }
}
