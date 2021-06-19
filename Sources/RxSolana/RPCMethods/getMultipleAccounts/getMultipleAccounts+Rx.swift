import Foundation
import RxSwift
import Solana

extension Solana {
    public func getMultipleAccounts<T: BufferLayout>(pubkeys: [String], decodedTo: T.Type) -> Single<[BufferInfo<T>]?> {
        Single.create { emitter in
            self.getMultipleAccounts(pubkeys: pubkeys, decodedTo: decodedTo) {
                switch $0 {
                case .success(let buffers):
                    emitter(.success(buffers))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
