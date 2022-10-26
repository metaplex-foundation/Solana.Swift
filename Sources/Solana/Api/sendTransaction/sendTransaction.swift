import Foundation

public extension Api {
    /// Submits a signed transaction to the cluster for processing.
    /// 
    /// This method does not alter the transaction in any way; it relays the
    ///  transaction created by clients to the node as-is.
    /// 
    /// If the node's rpc service receives the transaction, this method immediately succeeds,
    ///  without waiting for any confirmations. A successful response from this method
    ///  does not guarantee the transaction is processed or confirmed by the cluster.
    /// 
    /// While the rpc service will reasonably retry to submit it, the transaction could be 
    /// rejected if transaction's recent_blockhash expires before it lands.
    /// 
    /// Use getSignatureStatuses to ensure a transaction is processed and confirmed.
    /// 
    /// Before submitting, the following preflight checks are performed:
    /// 
    /// - The transaction signatures are verified
    /// - The transaction is simulated against the bank slot specified by the preflight commitment.
    ///  On failure an error will be returned. Preflight checks may be disabled if desired. It is recommended
    ///  to specify the same commitment and preflight commitment to avoid confusing behavior.
    /// 
    ///  The returned signature is the first signature in the transaction, which is used to identify
    ///  the transaction (transaction id). This identifier can be easily extracted from the transaction data before submission. 
    ///   
    /// - Parameters:
    ///   - serializedTransaction: fully-signed Transaction, as encoded string
    ///   - configs: Configuration object 
    ///   - onComplete: The result object of the first Transaction Signature embedded in the transaction, as base-58 encoded string (transaction id)
    func sendTransaction(serializedTransaction: String,
                         configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!,
                         onComplete: @escaping(Result<TransactionID, Error>) -> Void) {
        router.request(parameters: [serializedTransaction, configs]) { (result: Result<TransactionID, Error>) in
            switch result {
            case .success(let transaction):
                onComplete(.success(transaction))
            case .failure(let error):
                if let solanaError = error as? SolanaError {
                    onComplete(.failure(self.handleError(error: solanaError)))
                    return
                } else {
                    onComplete(.failure(error))
                    return
                }
            }
        }
    }

    fileprivate func handleError(error: SolanaError) -> Error {
        if case .invalidResponse(let response) = error,
           response.message != nil {
            var message = response.message
            if let readableMessage = response.data?.logs
                .first(where: { $0.contains("Error:") })?
                .components(separatedBy: "Error: ")
                .last {
                message = readableMessage
            } else if let readableMessage = response.message?
                        .components(separatedBy: "Transaction simulation failed: ")
                        .last {
                message = readableMessage
            }
            return SolanaError.invalidResponse(ResponseError(code: response.code, message: message, data: response.data))
        }
        return error
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Submits a signed transaction to the cluster for processing.
    /// 
    /// This method does not alter the transaction in any way; it relays the
    ///  transaction created by clients to the node as-is.
    /// 
    /// If the node's rpc service receives the transaction, this method immediately succeeds,
    ///  without waiting for any confirmations. A successful response from this method
    ///  does not guarantee the transaction is processed or confirmed by the cluster.
    /// 
    /// While the rpc service will reasonably retry to submit it, the transaction could be 
    /// rejected if transaction's recent_blockhash expires before it lands.
    /// 
    /// Use getSignatureStatuses to ensure a transaction is processed and confirmed.
    /// 
    /// Before submitting, the following preflight checks are performed:
    /// 
    /// - The transaction signatures are verified
    /// - The transaction is simulated against the bank slot specified by the preflight commitment.
    ///  On failure an error will be returned. Preflight checks may be disabled if desired. It is recommended
    ///  to specify the same commitment and preflight commitment to avoid confusing behavior.
    /// 
    ///  The returned signature is the first signature in the transaction, which is used to identify
    ///  the transaction (transaction id). This identifier can be easily extracted from the transaction data before submission. 
    ///   
    /// - Parameters:
    ///   - serializedTransaction: fully-signed Transaction, as encoded string
    ///   - configs: Configuration object 
    /// - Returns: The result object of the first Transaction Signature embedded in the transaction, as base-58 encoded string (transaction id)
    func sendTransaction(serializedTransaction: String,
                         configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) async throws -> TransactionID {
        try await withCheckedThrowingContinuation { c in
            self.sendTransaction(serializedTransaction: serializedTransaction, configs: configs, onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct SendTransaction: ApiTemplate {
        public init(serializedTransaction: String,
                    configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) {
            self.serializedTransaction = serializedTransaction
            self.configs = configs
        }

        public let serializedTransaction: String
        public let configs: RequestConfiguration

        public typealias Success = TransactionID

        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.sendTransaction(serializedTransaction: serializedTransaction, configs: configs, onComplete: completion)
        }
    }
}
