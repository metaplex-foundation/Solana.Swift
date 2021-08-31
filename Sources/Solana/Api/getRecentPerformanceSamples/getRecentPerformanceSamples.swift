import Foundation

public extension Api {
    func getRecentPerformanceSamples(limit: UInt64, onComplete: @escaping(Result<[PerformanceSample], Error>) -> Void) {
        router.request(parameters: [limit]) { (result: Result<[PerformanceSample], Error>) in
            switch result {
            case .success(let samples):
                onComplete(.success(samples))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

public extension ApiTemplates {
    struct GetRecentPerformanceSamples: ApiTemplate {
        public init(limit: UInt64) {
            self.limit = limit
        }
        
        public let limit: UInt64
        
        public typealias Success = [PerformanceSample]
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getRecentPerformanceSamples(limit: limit, onComplete: completion)
        }
    }
}
