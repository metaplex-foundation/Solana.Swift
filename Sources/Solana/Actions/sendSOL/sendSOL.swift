import Foundation

extension Action {
    public func sendSOL(
        to destination: String,
        from: Account,
        amount: UInt64,
        onComplete: @escaping ((Result<TransactionID, Error>) -> Void)
    ) {
        let account = from
        let fromPublicKey = account.publicKey
        if fromPublicKey.base58EncodedString == destination {
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
            guard let to = PublicKey(string: destination) else {
                onComplete(.failure(SolanaError.invalidPublicKey))
                return
            }

            let instruction = SystemProgram.transferInstruction(
                from: fromPublicKey,
                to: to,
                lamports: amount
            )
            self.serializeAndSendWithFee(
                instructions: [instruction],
                signers: [account],
                feePayer: account.publicKey
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

extension ActionTemplates {
    public struct SendSOL: ActionTemplate {
        public init(amount: UInt64, destination: String, from: Account) {
            self.amount = amount
            self.destination = destination
            self.from = from
        }

        public typealias Success = TransactionID
        public let amount: UInt64
        public let destination: String
        public let from: Account

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<TransactionID, Error>) -> Void) {
            actionClass.sendSOL(to: destination, from: from, amount: amount, onComplete: completion)
        }
    }
}
