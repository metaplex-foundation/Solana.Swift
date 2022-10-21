import Foundation

public extension Api {
    /// Returns the current inflation governor
    /// - Parameters:
    ///   - commitment: The commitment describes how finalized a block is at that point in time. (finalized, confirmed, processed)
    ///   - onComplete: The result object of InflationGovernor(foundation: Float64, foundationTerm: Float64, initial: Float64, taper: Float64, terminal: Float64)
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

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns the current inflation governor
    /// - Parameters:
    ///   - commitment: The commitment describes how finalized a block is at that point in time. (finalized, confirmed, processed)
    /// - Returns: The InflationGovernor(foundation: Float64, foundationTerm: Float64, initial: Float64, taper: Float64, terminal: Float64)
    func getInflationGovernor(commitment: Commitment? = nil) async throws -> InflationGovernor {
        try await withCheckedThrowingContinuation { c in
            self.getInflationGovernor(commitment: commitment, onComplete: c.resume(with:))
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
