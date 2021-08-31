import Foundation

public extension Api {
    func getInflationGovernor(commitment: Commitment? = nil, onComplete: @escaping(Result<InflationGovernor, Error>) -> Void) {
        router.request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<InflationGovernor, Error>) in
            switch result {
            case .success(let governor):
                onComplete(.success(governor))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

public extension ApiTemplates {
    struct GetInflationGovernor: ApiTemplate {
        public init(commitment: Commitment? = nil) {
            self.commitment = commitment
        }
        
        public let commitment: Commitment?
        
        public typealias Success = InflationGovernor
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getInflationGovernor(commitment: commitment, onComplete: completion)
        }
    }
}
