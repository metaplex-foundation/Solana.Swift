import Foundation
import RxSwift
import Solana

public extension Api {
    func getLeaderSchedule(epoch: UInt64? = nil, commitment: Commitment? = nil) -> Single<[String: [Int]]?> {
        Single.create { emitter in
            self.getLeaderSchedule(epoch: epoch, commitment: commitment) {
                switch $0 {
                case .success(let array):
                    emitter(.success(array))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
