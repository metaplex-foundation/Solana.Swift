import Foundation
import RxSwift

extension Solana {
    func getBlockTime(block: UInt64) -> Single<Date?> {
        Single.create { emitter in
            self.getBlockTime(block: block) {
                switch $0 {
                case .success(let date):
                    emitter(.success(date))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
