import Foundation
import RxSwift

extension Solana {
    func getEpochInfo(commitment: Commitment? = nil) -> Single<EpochInfo> {
        Single.create { emitter in
            self.getEpochInfo(commitment: commitment) {
                switch $0 {
                case .success(let epoch):
                    emitter(.success(epoch))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
