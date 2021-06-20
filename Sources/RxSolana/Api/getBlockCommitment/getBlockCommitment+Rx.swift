import Foundation
import RxSwift
import Solana


public extension Api {
    func getBlockCommitment(block: UInt64) -> Single<BlockCommitment> {
        Single.create { emitter in
            self.getBlockCommitment(block: block) {
                switch $0 {
                case .success(let blockCommitment):
                    emitter(.success(blockCommitment))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
