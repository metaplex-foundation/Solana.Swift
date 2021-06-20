import Foundation
import RxSwift
import Solana

extension Api {
    public func serializeAndSendWithFee(
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
extension Api {
    public func serializeAndSendWithFeeSimulation(
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
