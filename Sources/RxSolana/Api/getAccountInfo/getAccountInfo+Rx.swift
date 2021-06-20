import Foundation
import RxSwift
import Solana

public extension Api {
    func getAccountInfo<T: BufferLayout>(account: String, decodedTo: T.Type) -> Single<BufferInfo<T>> {
        Single.create { emitter in
            self.getAccountInfo(account: account, decodedTo: decodedTo) {
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
