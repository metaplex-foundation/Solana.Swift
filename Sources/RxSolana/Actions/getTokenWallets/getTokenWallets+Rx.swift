import Foundation
import RxSwift
import Solana

extension Action {
    public func getTokenWallets(account: String? = nil) -> Single<[Wallet]> {
        Single.create { emitter in
            self.getTokenWallets(account: account) { result in
                switch result {
                case .success(let wallets):
                    return emitter(.success(wallets))
                case .failure(let error):
                    return emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
