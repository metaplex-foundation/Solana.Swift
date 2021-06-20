import Foundation
import RxSwift
import Solana

public extension Api {
    func getFeeRateGovernor() -> Single<Fee> {
        Single.create { emitter in
            self.getFeeRateGovernor {
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
