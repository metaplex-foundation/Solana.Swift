import Foundation

public extension Api {
    /// Returns the token balance of an SPL Token account.
    /// 
    /// - Parameters:
    ///   - pubkey: Pubkey of Token account to query, as base-58 encoded string
    ///   - commitment: The commitment describes how finalized a block is at that point in time. (finalized, confirmed, processed)
    ///   - onComplete: Result Object of TokenAccountBalance(uiAmount: Float64?, amount: String, decimals: UInt8?, uiAmountString: String?)
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

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns the token balance of an SPL Token account.
    /// 
    /// - Parameters:
    ///   - pubkey: `PublicKey` of Token account to query, as base-58 encoded string
    ///   - commitment: The commitment describes how finalized a block is at that point in time (finalized, confirmed, processed)
    /// - Returns: TokenAccountBalance(uiAmount: Float64?, amount: String, decimals: UInt8?, uiAmountString: String?)
    func getTokenAccountBalance(pubkey: String, commitment: Commitment? = nil) async throws -> TokenAccountBalance {
        try await withCheckedThrowingContinuation { c in
            self.getTokenAccountBalance(pubkey: pubkey, commitment: commitment, onComplete: c.resume(with:))
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
