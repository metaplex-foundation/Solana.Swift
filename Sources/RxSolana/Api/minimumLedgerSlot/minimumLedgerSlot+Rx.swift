import Foundation
import RxSwift
import Solana

public extension Api {
    func minimumLedgerSlot() -> Single<UInt64> {
        Single.create { emitter in
            self.minimumLedgerSlot {
                switch $0 {
                case .success(let slot):
                    emitter(.success(slot))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
