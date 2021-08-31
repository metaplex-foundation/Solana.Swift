import Foundation

public extension Api {
    func getFeeRateGovernor(onComplete: @escaping (Result<Fee, Error>) -> Void) {
        router.request { (result: Result<Rpc<Fee?>, Error>) in
            switch result {
            case .success(let rpc):
                guard let value = rpc.value else {
                    onComplete(.failure(SolanaError.nullValue))
                    return
                }
                onComplete(.success(value))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

public extension ApiTemplates {
    struct GetFeeRateGovernor: ApiTemplate {
        public init() {}
        
        public typealias Success = Fee
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getFeeRateGovernor(onComplete: completion)
        }
    }
}
