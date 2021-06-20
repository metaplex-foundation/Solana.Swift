import Foundation
import RxSwift
import Solana

public extension Api {
    func getSlotLeader(commitment: Commitment? = nil) -> Single<String> {
        Single.create { emitter in
            self.getSlotLeader(commitment: commitment) {
                switch $0 {
                case .success(let hash):
                    emitter(.success(hash))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
