import Foundation
import RxSwift

public extension Solana {
    @available(*, deprecated, message: "Use getBlock insted")
    func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) -> Single<[UInt64]> {
        Single.create { emitter in
            self.getConfirmedBlocksWithLimit(startSlot: startSlot, limit: limit) {
                switch $0 {
                case .success(let confirmedBlocks):
                    emitter(.success(confirmedBlocks))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
