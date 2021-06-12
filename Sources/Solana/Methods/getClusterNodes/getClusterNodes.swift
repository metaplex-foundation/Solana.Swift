import Foundation

extension Solana {
    func getClusterNodes(onComplete: @escaping (Result<[ClusterNodes], Error>) -> ()){
        request() { (result: Result<[ClusterNodes], Error>) in
            switch result {
            case .success(let nodes):
                onComplete(.success(nodes))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
