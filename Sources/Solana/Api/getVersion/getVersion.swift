import Foundation

public extension Api {
    /// Returns the current solana versions running on the node
    /// 
    /// - Parameter onComplete: The result object of Version(solana-core, software version of solana-core. feature-set, unique identifier of the current software's feature set)
    func getVersion(onComplete: @escaping(Result<Version, Error>) -> Void) {
        router.request { (result: Result<Version, Error>) in
            switch result {
            case .success(let version):
                onComplete(.success(version))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns the current solana versions running on the node
    /// 
    /// - Returns: The result object of Version(solana-core, software version of solana-core. feature-set, unique identifier of the current software's feature set)
    func getVersion() async throws -> Version {
        try await withCheckedThrowingContinuation { c in
            self.getVersion(onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetVersion: ApiTemplate {
        public init() {}
        
        public typealias Success = Version
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getVersion(onComplete: completion)
        }
    }
}
