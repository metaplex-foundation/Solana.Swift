import Foundation

public extension Api {
    func getFirstAvailableBlock(onComplete: @escaping (Result<UInt64, Error>) -> Void) {
        router.request { (result: Result<UInt64, Error>) in
            switch result {
            case .success(let block):
                onComplete(.success(block))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

public extension ApiTemplates {
    struct GetFirstAvailableBlock: ApiTemplate {
        public init() {}
        
        public typealias Success = UInt64
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getFirstAvailableBlock(onComplete: completion)
        }
    }
}
