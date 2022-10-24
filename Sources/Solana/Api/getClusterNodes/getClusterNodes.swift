import Foundation

public extension Api {
    /// Returns information about all the nodes participating in the cluster
    /// 
    /// - Parameter onComplete: The result type will be an array of ClusterNodes objects
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

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns information about all the nodes participating in the cluster
    /// 
    /// - Returns: The result type will be an array of `ClusterNodes` objects
    func getClusterNodes() async throws -> [ClusterNodes] {
        try await withCheckedThrowingContinuation { c in
            self.getClusterNodes(onComplete: c.resume(with:))
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
