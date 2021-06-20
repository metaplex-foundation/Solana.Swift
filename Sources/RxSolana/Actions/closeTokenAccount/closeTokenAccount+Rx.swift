import Foundation
import RxSwift
import Solana

extension Action {
    public func closeTokenAccount(
        account: Account? = nil,
        tokenPubkey: String
    ) -> Single<TransactionID> {
        Single.create { emitter in
            self.closeTokenAccount(account: account, tokenPubkey: tokenPubkey) {
                switch $0 {
                case .success(let bufferInfo):
                    emitter(.success(bufferInfo))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
