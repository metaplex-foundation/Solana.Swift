import Foundation
import RxSwift
import Solana

public extension Api {
    func getConfirmedBlocks(startSlot: UInt64, endSlot: UInt64) -> Single<[UInt64]> {
        Single.create { emitter in
            self.getConfirmedBlocks(startSlot: startSlot, endSlot: endSlot) {
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
