import Foundation

public extension Api {
    func getClusterNodes(onComplete: @escaping (Result<[ClusterNodes], Error>) -> Void) {
        router.request { (result: Result<[ClusterNodes], Error>) in
            switch result {
            case .success(let nodes):
                onComplete(.success(nodes))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
