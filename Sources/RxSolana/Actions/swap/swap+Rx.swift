import Foundation
import RxSwift
import Solana

private let swapProgramId = "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8"
extension Action {
    public func swap(
        account: Account? = nil,
        pool: Pool? = nil,
        source: PublicKey,
        sourceMint: PublicKey,
        destination: PublicKey? = nil,
        destinationMint: PublicKey,
        slippage: Double,
        amount: UInt64
    ) -> Single<SwapResponse> {
        Single.create { emitter in
            self.swap(account: account,
                      pool: pool,
                      source: source,
                      sourceMint: sourceMint,
                      destination: destination,
                      destinationMint: destinationMint,
                      slippage: slippage,
                      amount: amount) {
                switch $0 {
                case .success(let swapResponse):
                    emitter(.success(swapResponse))
                    return
                case .failure(let error):
                    emitter(.failure(error))
                    return
                }
            }
            return Disposables.create()
        }
    }

    public func getAccountInfoData(account: String, tokenProgramId: PublicKey) -> Single<AccountInfo> {
        Single.create { emitter in
            self.getAccountInfoData(account: account, tokenProgramId: tokenProgramId) {
                switch $0 {
                case .success(let accountInfo):
                    emitter(.success(accountInfo))
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
