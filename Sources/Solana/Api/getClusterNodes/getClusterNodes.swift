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

public extension ApiTemplates {
    struct GetClusterNodes: ApiTemplate {
        public init() {}
        
        public typealias Success = [ClusterNodes]
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getClusterNodes(onComplete: completion)
        }
    }
}
