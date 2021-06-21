import Foundation
import RxSwift
import Solana

public extension Api {
    func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment? = nil) -> Single<String> {
        Single.create { emitter in
            self.requestAirdrop(account: account, lamports: lamports, commitment: commitment) {
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
