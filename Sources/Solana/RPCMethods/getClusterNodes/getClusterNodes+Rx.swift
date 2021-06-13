import Foundation
import RxSwift

extension Solana {
    func getClusterNodes() -> Single<[ClusterNodes]> {
        Single.create { emitter in
            self.getClusterNodes {
                switch $0 {
                case .success(let nodes):
                    emitter(.success(nodes))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
