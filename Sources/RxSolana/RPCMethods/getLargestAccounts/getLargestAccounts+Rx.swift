import Foundation
import RxSwift
import Solana

extension Solana {
    public func getLargestAccounts() -> Single<[LargestAccount]> {
        Single.create { emitter in
            self.getLargestAccounts {
                switch $0 {
                case .success(let accounts):
                    emitter(.success(accounts))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
