import Foundation
import RxSwift
import Solana

public extension Api {
    func getProgramAccounts<T: BufferLayout>(publicKey: String, configs: RequestConfiguration? = RequestConfiguration(encoding: "base64"), decodedTo: T.Type) -> Single<[ProgramAccount<T>]> {
        Single.create { emitter in
            self.getProgramAccounts(publicKey: publicKey, configs: configs, decodedTo: decodedTo) {
                switch $0 {
                case .success(let accounts):
                    emitter(.success(accounts))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
