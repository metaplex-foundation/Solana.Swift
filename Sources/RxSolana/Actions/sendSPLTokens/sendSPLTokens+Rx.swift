import Foundation
import RxSwift
import Solana

extension Action {
    public func sendSPLTokens(
        mintAddress: PublicKey,
        decimals: Decimals,
        from fromPublicKey: PublicKey,
        to destinationAddress: PublicKey,
        amount: UInt64
    ) -> Single<TransactionID> {
        Single.create { emitter in
            self.sendSPLTokens(mintAddress: mintAddress,
                               decimals: decimals,
                               from: fromPublicKey,
                               to: destinationAddress,
                               amount: amount
            ) { result in
                switch result {
                case .success(let transaction):
                    emitter(.success(transaction))
                    return
                case .failure(let error):
                    emitter(.failure(error))
                    return
                }
            }
            return Disposables.create()
        }
    }
}
