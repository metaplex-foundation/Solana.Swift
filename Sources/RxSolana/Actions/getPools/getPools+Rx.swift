import Foundation
import RxSwift
import Solana

private var mintDatasCache = [Mint]()
private let swapProgramId = "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8"
extension Action {

    public func getSwapPools() -> Single<[Pool]> {
        getPools(swapProgramId: swapProgramId)
            .map {
                $0.filter {
                    $0.tokenABalance?.amountInUInt64 != 0 &&
                        $0.tokenBBalance?.amountInUInt64 != 0
                }
            }
    }

    public func getPools(swapProgramId: String) -> Single<[Pool]> {
        Single.create { emitter in
            self.getPools(swapProgramId: swapProgramId) { result in
                switch result {
                case .success(let pools):
                    return emitter(.success(pools))
                case .failure(let error):
                    return emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    public func getPoolWithTokenBalances(pool: Pool) -> Single<Pool> {
        Single.create { emitter in
            self.getPoolWithTokenBalances(pool: pool) { result in
                switch result {
                case .success(let pool):
                    return emitter(.success(pool))
                case .failure(let error):
                    return emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
