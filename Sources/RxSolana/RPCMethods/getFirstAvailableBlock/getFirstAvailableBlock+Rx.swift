import Foundation
import RxSwift
import Solana

extension Solana {
    public func getFirstAvailableBlock() -> Single<UInt64> {
        Single.create { emitter in
            self.getFirstAvailableBlock {
                switch $0 {
                case .success(let block):
                    emitter(.success(block))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
