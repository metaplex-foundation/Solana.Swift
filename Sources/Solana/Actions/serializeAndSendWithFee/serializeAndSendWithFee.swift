import Foundation

extension Solana {
    fileprivate func retryOrError(instructions: [TransactionInstruction],
                                  recentBlockhash: String? = nil,
                                  signers: [Account],
                                  maxAttemps: Int = 3,
                                  numberOfTries: Int = 0,
                                  error: Error,
                                  onComplete: @escaping ((Result<String, Error>) -> ())) {
        var numberOfTries = numberOfTries
        if numberOfTries <= maxAttemps,
           let error = error as? SolanaError
        {
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
    
    func serializeAndSendWithFee(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        maxAttemps: Int = 3,
        numberOfTries: Int = 0,
        onComplete: @escaping ((Result<String, Error>) -> ())
    ){
        serializeTransaction(instructions: instructions, recentBlockhash: recentBlockhash, signers: signers){ result in
            switch result {
            case .success(let transaction):
                self.sendTransaction(serializedTransaction: transaction) {
                    switch $0{
                    case .success(let hash):
                        onComplete(.success(hash))
                        return
                    case .failure(let error):
                        self.retryOrError(instructions: instructions,
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
extension Solana {
    fileprivate func retrySimulateOrError(instructions: [TransactionInstruction],
                                          recentBlockhash: String? = nil,
                                          signers: [Account],
                                          maxAttemps: Int = 3,
                                          numberOfTries: Int = 0,
                                          error: (Error),
                                          onComplete: @escaping ((Result<String, Error>) -> ())) {
        var numberOfTries = numberOfTries
        if numberOfTries <= maxAttemps,
           let error = error as? SolanaError
        {
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
    
    func serializeAndSendWithFeeSimulation(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        maxAttemps: Int = 3,
        numberOfTries: Int = 0,
        onComplete: @escaping((Result<String, Error>) -> ())
    ) {
        serializeTransaction(instructions: instructions, recentBlockhash: recentBlockhash, signers: signers){ result in
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
                                                    onComplete:onComplete)
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
