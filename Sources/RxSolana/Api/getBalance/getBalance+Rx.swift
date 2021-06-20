import Foundation
import RxSwift
import Solana


public extension Api {
    func getBalance(account: String? = nil, commitment: Commitment? = nil) -> Single<UInt64> {
        Single.create { emitter in
            self.getBalance(account: account, commitment: commitment) {
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
