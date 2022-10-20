import Foundation

extension Action {
    public func sendSOL(
        to destination: String,
        from: Account,
        amount: UInt64,
        allowUnfundedRecipient: Bool = false,
        onComplete: @escaping ((Result<TransactionID, Error>) -> Void)
    ) {
        let account = from
        let fromPublicKey = account.publicKey
        if fromPublicKey.base58EncodedString == destination {
            onComplete(.failure(SolanaError.other("You can not send tokens to yourself")))
            return
        }

        // check

        api.getAccountInfo(account: destination, decodedTo: EmptyInfo.self,
                                         allowUnfundedRecipient:allowUnfundedRecipient) { resultInfo in
            if case let Result.failure(error) = resultInfo {
                if let solanaError = error as? SolanaError,
                   case SolanaError.couldNotRetriveAccountInfo = solanaError {
                    // let request through
                } else {
                    onComplete(.failure(error))
                    return
                }
            }
            if allowUnfundedRecipient == false {
                guard case let Result.success(info) = resultInfo else {
                    onComplete(.failure(SolanaError.couldNotRetriveAccountInfo))
                    return
                }

                guard info?.owner == PublicKey.systemProgramId.base58EncodedString else {
                    onComplete(.failure(SolanaError.other("Invalid account info")))
                    return
                }
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
                signers: [account]
            ) {
                switch $0 {
                case let .success(transaction):
                    onComplete(.success(transaction))
                case let .failure(error):
                    onComplete(.failure(error))
                }
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Action {
    func sendSOL(
        to destination: String,
        from: Account,
        amount: UInt64
    ) async throws -> TransactionID {
        try await withCheckedThrowingContinuation { c in
            self.sendSOL(to: destination, from: from, amount: amount, onComplete: c.resume(with:))
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
