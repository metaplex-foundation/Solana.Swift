import Foundation

public extension Api {
    /// Returns the 20 largest accounts of a particular SPL Token type.
    /// 
    /// - Parameters:
    ///   - pubkey: Pubkey of token Mint to query, as base-58 encoded string
    ///   - commitment: The commitment describes how finalized a block is at that point in time. (finalized, confirmed, processed)
    ///   - onComplete: An Result object of an array of TokenAmount(amount: String decimals: UInt8, uiAmount: Float64, uiAmountString: String)
    func getTokenLargestAccounts(pubkey: String, commitment: Commitment? = nil, onComplete: @escaping (Result<[TokenAmount], Error>) -> Void) {
        router.request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) { (result: Result<Rpc<[TokenAmount]?>, Error>) in
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

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns the 20 largest accounts of a particular SPL Token type.
    /// 
    /// - Parameters:
    ///   - pubkey: Pubkey of token Mint to query, as base-58 encoded string
    ///   - commitment: The commitment describes how finalized a block is at that point in time. (finalized, confirmed, processed)
    /// - Returns: An Result object of an array of TokenAmount(amount: String decimals: UInt8, uiAmount: Float64, uiAmountString: String)
    func getTokenLargestAccounts(pubkey: String, commitment: Commitment? = nil) async throws -> [TokenAmount] {
        try await withCheckedThrowingContinuation { c in
            self.getTokenLargestAccounts(pubkey: pubkey, commitment: commitment, onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetTokenLargestAccounts: ApiTemplate {
        public init(pubkey: String, commitment: Commitment? = nil) {
            self.pubkey = pubkey
            self.commitment = commitment
        }
        
        public let pubkey: String
        public let commitment: Commitment?
        
        public typealias Success = [TokenAmount]
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getTokenLargestAccounts(pubkey: pubkey, commitment: commitment, onComplete: completion)
        }
    }
}
