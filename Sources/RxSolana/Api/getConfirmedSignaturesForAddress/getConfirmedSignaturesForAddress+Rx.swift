import Foundation
import RxSwift
import Solana

public extension Api {
    public func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) -> Single<[String]> {
        Single.create { emitter in
            self.getConfirmedSignaturesForAddress(account: account, startSlot: startSlot, endSlot: endSlot) {
                switch $0 {
                case .success(let signatures):
                    emitter(.success(signatures))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
