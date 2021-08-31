import Foundation

public extension Api {
    func getGenesisHash(onComplete: @escaping(Result<String, Error>) -> Void) {
        router.request { (result: Result<String, Error>) in
            switch result {
            case .success(let hash):
                onComplete(.success(hash))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

public extension ApiTemplates {
    struct GetGenesisHash: ApiTemplate {
        public init() {}
        
        public typealias Success = String
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getGenesisHash(onComplete: completion)
        }
    }
}
