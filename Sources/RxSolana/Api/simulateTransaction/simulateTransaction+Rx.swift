import Foundation
import RxSwift
import Solana

public extension Api {
    func simulateTransaction(transaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) -> Single<TransactionStatus> {
        Single.create { emitter in
            self.simulateTransaction(transaction: transaction, configs: configs) {
                switch $0 {
                case .success(let status):
                    emitter(.success(status))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
