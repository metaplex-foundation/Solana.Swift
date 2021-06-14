import Foundation
import RxSwift

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
    
    func serializeAndSendWithFee(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        maxAttemps: Int = 3,
        numberOfTries: Int = 0
    ) -> Single<String> {
        Single.create { emitter in
            self.serializeAndSendWithFee(instructions: instructions,
                                         recentBlockhash: recentBlockhash,
                                         signers: signers,
                                         maxAttemps: maxAttemps,
                                         numberOfTries: numberOfTries
            ) { result in
                switch result {
                case .success(let transaction):
                    emitter(.success(transaction))
                    return
                case .failure(let error):
                    emitter(.failure(error))
                    return
                }
            }
            return Disposables.create()
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
    
    func serializeAndSendWithFeeSimulation(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        maxAttemps: Int = 3,
        numberOfTries: Int = 0
    ) -> Single<String> {
        Single.create { emitter in
            self.serializeAndSendWithFeeSimulation(instructions: instructions,
                                                   recentBlockhash: recentBlockhash,
                                                   signers: signers,
                                                   maxAttemps: maxAttemps,
                                                   numberOfTries: numberOfTries
            ) { result in
                switch result {
                case .success(let transaction):
                    emitter(.success(transaction))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}

extension Solana {
    private func serializeTransaction(
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
    
    private func serializeTransaction(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        feePayer: PublicKey? = nil
    ) -> Single<String> {
        Single.create { emitter in
            self.serializeTransaction(instructions: instructions, recentBlockhash: recentBlockhash, signers: signers, feePayer: feePayer) { result in
                switch result {
                case .success(let transaction):
                    emitter(.success(transaction))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
