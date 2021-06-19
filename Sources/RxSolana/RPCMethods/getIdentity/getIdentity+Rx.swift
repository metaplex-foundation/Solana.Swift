import Foundation
import RxSwift
import Solana

extension Solana {
    public func getIdentity() -> Single<Identity> {
        Single.create { emitter in
            self.getIdentity {
                switch $0 {
                case .success(let identity):
                    emitter(.success(identity))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
