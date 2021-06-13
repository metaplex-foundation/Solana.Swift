import Foundation
import RxSwift

extension Solana {
    func getGenesisHash() -> Single<String> {
        Single.create { emitter in
            self.getGenesisHash {
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
