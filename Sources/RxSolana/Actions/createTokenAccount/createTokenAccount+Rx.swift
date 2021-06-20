import Foundation
import RxSwift
import Solana

extension Action {
    public func createTokenAccount(
        mintAddress: String
    ) -> Single<(signature: String, newPubkey: String)> {
        Single.create { emitter in
            self.createTokenAccount(mintAddress: mintAddress) {
                switch $0 {
                case .success(let transaction):
                    emitter(.success(transaction))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    public func getCreatingTokenAccountFee() -> Single<UInt64> {
        Single.create { emitter in
            self.getCreatingTokenAccountFee {
                switch $0 {
                case .success(let fee):
                    emitter(.success(fee))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
