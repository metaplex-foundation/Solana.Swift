import Foundation
import RxSwift
import Solana

public extension Api {
    func getLargestAccounts() -> Single<[LargestAccount]> {
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
