import Foundation

public extension Api {
    /// Returns the current Transaction count from the ledger
    /// 
    /// - Parameters:
    ///   - commitment: The commitment describes how finalized a block is at that point in time (finalized, confirmed, processed)
    ///   - onComplete: The Result object of count UInt64
    func getTransactionCount(commitment: Commitment? = nil, onComplete: @escaping (Result<UInt64, Error>) -> Void) {
        router.request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<UInt64, Error>) in
            switch result {
            case .success(let count):
                onComplete(.success(count))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns the current Transaction count from the ledger
    /// 
    /// - Parameters:
    ///   - commitment: The commitment describes how finalized a block is at that point in time (finalized, confirmed, processed)
    /// - Returns: The count UInt64
    func getTransactionCount(commitment: Commitment? = nil) async throws -> UInt64 {
        try await withCheckedThrowingContinuation { c in
            self.getTransactionCount(commitment: commitment, onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetTransactionCount: ApiTemplate {
        public init(commitment: Commitment? = nil) {
            self.commitment = commitment
        }
        
        public let commitment: Commitment?
        
        public typealias Success = UInt64
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getTransactionCount(commitment: commitment, onComplete: completion)
        }
    }
}
