import Foundation

public extension Api {
    func getStakeActivation(stakeAccount: String, configs: RequestConfiguration? = nil, onComplete: @escaping (Result<StakeActivation, Error>) -> Void) {
        router.request(parameters: [stakeAccount, configs]) { (result: Result<StakeActivation, Error>) in
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
    struct GetStakeActivation: ApiTemplate {
        public init(stakeAccount: String, configs: RequestConfiguration? = nil) {
            self.stakeAccount = stakeAccount
            self.configs = configs
        }
        
        public let stakeAccount: String
        public let configs: RequestConfiguration?
        
        public typealias Success = StakeActivation
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getStakeActivation(stakeAccount: stakeAccount, configs: configs, onComplete: completion)
        }
    }
}
