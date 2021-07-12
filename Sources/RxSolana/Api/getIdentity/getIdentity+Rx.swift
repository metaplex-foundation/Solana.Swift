import Foundation
import RxSwift
import Solana

public extension Api {
    func getIdentity() -> Single<Identity> {
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
