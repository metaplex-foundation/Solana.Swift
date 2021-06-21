import Foundation
import RxSwift
import Solana

public extension Api {
    func sendTransaction(serializedTransaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) -> Single<TransactionID> {
        Single.create { emitter in
            self.sendTransaction(serializedTransaction: serializedTransaction, configs: configs) {
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
