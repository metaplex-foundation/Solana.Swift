import Foundation
import RxSwift

extension Solana {
    func getSupply(commitment: Commitment? = nil) -> Single<Supply> {
        Single.create { emitter in
            self.getSupply(commitment: commitment) {
                switch $0 {
                case .success(let suply):
                    emitter(.success(suply))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
