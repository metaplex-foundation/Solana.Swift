import Foundation

extension Solana {
    fileprivate func retryOrError(instructions: [TransactionInstruction],
                                  recentBlockhash: String? = nil,
                                  signers: [Account],
                                  maxAttemps: Int = 3,
                                  numberOfTries: Int = 0,
                                  error: Error,
                                  onComplete: @escaping ((Result<String, Error>) -> Void)) {
        var numberOfTries = numberOfTries
        if numberOfTries <= maxAttemps,
           let error = error as? SolanaError {
            if case SolanaError.blockHashNotFound = error {
                numberOfTries += 1
                self.serializeAndSendWithFee(instructions: instructions,
                                             signers: signers,
                                             maxAttemps: maxAttemps,
                                             numberOfTries: numberOfTries,
                                             onComplete: onComplete)
                return
            }
        }
        onComplete(.failure(error))
        return
    }

    public func serializeAndSendWithFee(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        maxAttemps: Int = 3,
        numberOfTries: Int = 0,
        onComplete: @escaping ((Result<String, Error>) -> Void)
    ) {

        ContResult.init { cb in
            self.serializeTransaction(instructions: instructions, recentBlockhash: recentBlockhash, signers: signers) {
                cb($0)
            }
        }.flatMap { transaction in
            return ContResult.init { cb in
                self.sendTransaction(serializedTransaction: transaction) {
                    cb($0)
                }
            }
        }.recover { error in
            var numberOfTries = numberOfTries
            if numberOfTries <= maxAttemps,
               let error = error as? SolanaError {
                if case SolanaError.blockHashNotFound = error {
                    numberOfTries += 1
                    return ContResult.init { cb in
                        self.serializeAndSendWithFee(instructions: instructions,
                                                     signers: signers,
                                                     maxAttemps: maxAttemps,
                                                     numberOfTries: numberOfTries,
                                                     onComplete: cb)
                    }
                }
            }
            return .failure(error)
        }
        .run(onComplete)
    }
}
extension Solana {
    fileprivate func retrySimulateOrError(instructions: [TransactionInstruction],
                                          recentBlockhash: String? = nil,
                                          signers: [Account],
                                          maxAttemps: Int = 3,
                                          numberOfTries: Int = 0,
                                          error: (Error),
                                          onComplete: @escaping ((Result<String, Error>) -> Void)) {
        var numberOfTries = numberOfTries
        if numberOfTries <= maxAttemps,
           let error = error as? SolanaError {
            if case SolanaError.blockHashNotFound = error {
                numberOfTries += 1
                self.serializeAndSendWithFeeSimulation(instructions: instructions,
                                                       signers: signers,
                                                       maxAttemps: maxAttemps,
                                                       numberOfTries: numberOfTries,
                                                       onComplete: onComplete)
                return
            }
        }
        onComplete(.failure(error))
        return
    }

    public func serializeAndSendWithFeeSimulation(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        maxAttemps: Int = 3,
        numberOfTries: Int = 0,
        onComplete: @escaping((Result<String, Error>) -> Void)
    ) {
        serializeTransaction(instructions: instructions, recentBlockhash: recentBlockhash, signers: signers) { result in
            switch result {
            case .success(let transaction):
                self.simulateTransaction(transaction: transaction) {
                    switch $0 {
                    case .success(let r):
                        if r.err != nil {
                            onComplete(.failure(SolanaError.other("Simulation error")))
                        }
                        onComplete(.success("SIMULATED_TRANSATION"))
                        return
                    case .failure(let error):
                        self.retrySimulateOrError(instructions: instructions,
                                                    recentBlockhash: recentBlockhash,
                                                    signers: signers,
                                                    maxAttemps: maxAttemps,
                                                    numberOfTries: numberOfTries,
                                                    error: error,
                                                    onComplete: onComplete)
                        return
                    }
                }
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }
    }
}
