import Foundation
import RxSwift

extension Solana {
    public func closeTokenAccount(
        account: Solana.Account? = nil,
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
