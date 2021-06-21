import Foundation
import RxSwift
import Solana

public extension Api {
    func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment? = "recent") -> Single<UInt64> {
        Single.create { emitter in
            self.getMinimumBalanceForRentExemption(dataLength: dataLength, commitment: commitment) {
                switch $0 {
                case .success(let rent):
                    emitter(.success(rent))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
