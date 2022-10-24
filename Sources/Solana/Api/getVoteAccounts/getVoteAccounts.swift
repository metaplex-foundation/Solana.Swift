import Foundation

public extension Api {
    /// Returns the account info and associated stake for all the voting accounts in the current bank.
    /// 
    /// - Parameters:
    ///   - commitment: The commitment describes how finalized a block is at that point in time (finalized, confirmed, processed)
    ///   - onComplete: The result object of VoteAccounts(current: [VoteAccount], delinquent: [VoteAccount])
    func getVoteAccounts(commitment: Commitment? = nil, onComplete: @escaping(Result<VoteAccounts, Error>) -> Void) {
        router.request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<VoteAccounts, Error>) in
            switch result {
            case .success(let accounts):
                onComplete(.success(accounts))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns the account info and associated stake for all the voting accounts in the current bank.
    /// 
    /// - Parameters:
    ///   - commitment: The commitment describes how finalized a block is at that point in time (finalized, confirmed, processed)
    /// - Returns: The result object of VoteAccounts(current: [VoteAccount], delinquent: [VoteAccount])
    func getVoteAccounts(commitment: Commitment? = nil) async throws -> VoteAccounts {
        try await withCheckedThrowingContinuation { c in
            self.getVoteAccounts(commitment: commitment, onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetVoteAccounts: ApiTemplate {
        public init(commitment: Commitment? = nil) {
            self.commitment = commitment
        }
        
        public let commitment: Commitment?
        
        public typealias Success = VoteAccounts
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getVoteAccounts(commitment: commitment, onComplete: completion)
        }
    }
}
