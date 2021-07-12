import Foundation
import RxSwift
import Solana

public extension Api {
    func getRecentPerformanceSamples(limit: UInt64) -> Single<[PerformanceSample]> {
        Single.create { emitter in
            self.getRecentPerformanceSamples(limit: limit) {
                switch $0 {
                case .success(let samples):
                    emitter(.success(samples))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
