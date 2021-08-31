import Foundation

public extension Api {
    func getIdentity(onComplete: @escaping(Result<Identity, Error>) -> Void) {
        router.request { (result: Result<Identity, Error>) in
            switch result {
            case .success(let identity):
                onComplete(.success(identity))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

public extension ApiTemplates {
    struct GetIdentity: ApiTemplate {
        public init() {}
        
        public typealias Success = Identity
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getIdentity(onComplete: completion)
        }
    }
}
