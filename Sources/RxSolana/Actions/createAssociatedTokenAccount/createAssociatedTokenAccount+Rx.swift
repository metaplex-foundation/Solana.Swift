import Foundation
import RxSwift
import Solana

extension Action {
    public func getOrCreateAssociatedTokenAccount(
        for owner: PublicKey,
        tokenMint: PublicKey
    ) -> Single<(transactionId: TransactionID?, associatedTokenAddress: PublicKey)> {
        Single.create { emitter in
            self.getOrCreateAssociatedTokenAccount(owner: owner, tokenMint: tokenMint) {
                switch $0 {
                case .success(let result):
                    emitter(.success(result))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    public func createAssociatedTokenAccount(
        for owner: PublicKey,
        tokenMint: PublicKey,
        payer: Account? = nil
    ) -> Single<TransactionID> {
        Single.create { emitter in
            self.createAssociatedTokenAccount(for: owner, tokenMint: tokenMint, payer: payer) {
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
