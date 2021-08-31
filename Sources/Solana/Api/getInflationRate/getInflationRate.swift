import Foundation

public extension Api {
    func getInflationRate(onComplete: @escaping(Result<InflationRate, Error>) -> Void) {
        router.request { (result: Result<InflationRate, Error>) in
            switch result {
            case .success(let rate):
                onComplete(.success(rate))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

public extension ApiTemplates {
    struct GetInflationRate: ApiTemplate {
        public init() {}
        
        public typealias Success = InflationRate
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getInflationRate(onComplete: completion)
        }
    }
}
