import Foundation
import RxSwift
import Solana

public extension Api {
    func getFeeCalculatorForBlockhash(blockhash: String, commitment: Commitment? = nil) -> Single<Fee> {
        Single.create { emitter in
            self.getFeeCalculatorForBlockhash(blockhash: blockhash, commitment: commitment) {
                switch $0 {
                case .success(let value):
                    emitter(.success(value))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
