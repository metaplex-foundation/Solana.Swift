import Foundation
import RxSwift
import Solana

extension Api {
    public func getVersion() -> Single<Version> {
        Single.create { emitter in
            self.getVersion {
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
