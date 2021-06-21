import Foundation
import RxSwift
import Solana

public extension Api {
    func getConfirmedSignaturesForAddress2(account: String, configs: RequestConfiguration? = nil) -> Single<[SignatureInfo]> {
        Single.create { emitter in
            self.getConfirmedSignaturesForAddress2(account: account, configs: configs) {
                switch $0 {
                case .success(let signatures):
                    emitter(.success(signatures))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
