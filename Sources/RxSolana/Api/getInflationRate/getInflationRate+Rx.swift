import Foundation
import RxSwift
import Solana

public extension Api {
    func getInflationRate() -> Single<InflationRate> {
        Single.create { emitter in
            self.getInflationRate {
                switch $0 {
                case .success(let rate):
                    emitter(.success(rate))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
