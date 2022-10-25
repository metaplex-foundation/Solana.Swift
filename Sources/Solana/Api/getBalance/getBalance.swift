import Foundation

public extension Api {
    /// Returns the balance of the account of provided `PublicKey`
    ///
    /// - Parameters:
    ///   - account: `PublicKey` of account to query, as base-58 encoded string
    ///   - commitment: The commitment describes how finalized a block is at that point in time (finalized, confirmed, processed)
    ///   - onComplete: The result object of `UInt64` balance of the account of provided `PublicKey`
    func getBalance(account: String, commitment: Commitment? = nil, onComplete: @escaping(Result<UInt64, Error>) -> Void) {
        router.request(parameters: [account, RequestConfiguration(commitment: commitment)]) { (result: Result<Rpc<UInt64?>, Error>) in
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
    /// Returns the balance of the account of provided `PublicKey`
    ///
    /// - Parameters:
    ///     - account: `PublicKey` of account to query, as base-58 encoded string
    ///     - commitment (Optional): The commitment describes how finalized a block is at that point in time
    /// - Returns: The balance `UInt64` of the account of provided `PublicKey`
    func getBalance(account: String, commitment: Commitment? = nil) async throws -> UInt64 {
        try await withCheckedThrowingContinuation { c in
            self.getBalance(account: account, commitment: commitment, onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetBalance: ApiTemplate {
        public init(account: String, commitment: Commitment? = nil) {
            self.account = account
            self.commitment = commitment
        }

        public let account: String
        public let commitment: Commitment?

        public typealias Success = UInt64

        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getBalance(account: account, commitment: commitment, onComplete: completion)
        }
    }
}
