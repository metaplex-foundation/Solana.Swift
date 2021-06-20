import Foundation
import RxSwift
import Solana

extension Action {
    public func sendSOL(
        to destination: String,
        amount: UInt64
    ) -> Single<TransactionID> {
        Single.create { emitter in
            self.sendSOL(to: destination, amount: amount) { result in
                switch result {
                case .success(let mint):
                    return emitter(.success(mint))
                case .failure(let error):
                    return emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
