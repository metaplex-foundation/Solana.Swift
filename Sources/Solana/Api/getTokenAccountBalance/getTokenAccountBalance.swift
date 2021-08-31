import Foundation

public extension Api {
    func getTokenAccountBalance(pubkey: String, commitment: Commitment? = nil, onComplete: @escaping (Result<TokenAccountBalance, Error>) -> Void) {
        router.request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) { (result: Result<Rpc<TokenAccountBalance?>, Error>) in
            switch result {
            case .success(let rpc):
                guard let value = rpc.value else {
                    onComplete(.failure(SolanaError.nullValue))
                    return
                }
                guard UInt64(value.amount) != nil else {
                    onComplete(.failure(SolanaError.couldNotRetriveBalance))
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
    struct GetTokenAccountBalance: ApiTemplate {
        public init(pubkey: String, commitment: Commitment? = nil) {
            self.pubkey = pubkey
            self.commitment = commitment
        }
        
        public let pubkey: String
        public let commitment: Commitment?
        
        public typealias Success = TokenAccountBalance
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getTokenAccountBalance(pubkey: pubkey, commitment: commitment, onComplete: completion)
        }
    }
}
