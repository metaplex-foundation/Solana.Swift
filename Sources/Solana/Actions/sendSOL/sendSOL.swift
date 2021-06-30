import Foundation
import RxSwift

extension Action {
    public func sendSOL(
        to destination: PublicKey,
        amount: UInt64,
        onComplete: @escaping ((Result<TransactionID, Error>) -> Void)
    ) {
        guard let account = try? self.auth.account.get() else {
            onComplete(.failure(SolanaError.unauthorized))
            return
        }

        let fromPublicKey = account.publicKey
        if fromPublicKey.base58EncodedString == destination.base58EncodedString {
            onComplete(.failure(SolanaError.other("You can not send tokens to yourself")))
            return
        }

        // check
        self.api.getAccountInfo(account: destination, decodedTo: EmptyInfo.self) { resultInfo in

            if case Result.failure( let error) = resultInfo {
                if let solanaError = error as? SolanaError,
                   case SolanaError.couldNotRetriveAccountInfo = solanaError {
                    // let request through
                } else {
                    onComplete(.failure(error))
                    return
                }
            }

            guard case Result.success(let info) = resultInfo else {
                onComplete(.failure(SolanaError.couldNotRetriveAccountInfo))
                return
            }

            guard info.owner == PublicKey.programId.base58EncodedString else {
                onComplete(.failure(SolanaError.other("Invalid account info")))
                return
            }
            

            let instruction = SystemProgram.transferInstruction(
                from: fromPublicKey,
                to: destination,
                lamports: amount
            )
            self.serializeAndSendWithFee(
                instructions: [instruction],
                signers: [account]
            ) {
                switch $0 {
                case .success(let transaction):
                    onComplete(.success(transaction))
                case .failure(let error):
                    onComplete(.failure(error))
                }
            }
        }

    }
}
