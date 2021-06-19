import Foundation

extension Solana {
    public func serializeTransaction(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        feePayer: PublicKey? = nil,
        onComplete: @escaping ((Result<String, Error>) -> Void)
    ) {

        guard let feePayer = feePayer ?? accountStorage.account?.publicKey else {
            onComplete(.failure(SolanaError.invalidRequest(reason: "Fee-payer not found")))
            return
        }

        let getRecentBlockhashRequest: (Result<String, Error>)->Void = { result in
            switch result {
            case .success(let recentBlockhash):

                var transaction = Transaction(
                    feePayer: feePayer,
                    instructions: instructions,
                    recentBlockhash: recentBlockhash
                )

                transaction.sign(signers: signers)
                .flatMap { transaction.serialize() }
                .flatMap {
                    if let base64 = $0.bytes.toBase64() {
                        return .success(base64)
                    } else {
                        return .failure(SolanaError.other("Could not serialize transaction"))
                    }
                }
                .onSuccess { onComplete(.success($0)) }
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }

        if let recentBlockhash = recentBlockhash {
            getRecentBlockhashRequest(.success(recentBlockhash))
        } else {
            getRecentBlockhash { getRecentBlockhashRequest($0) }
        }
    }
}
