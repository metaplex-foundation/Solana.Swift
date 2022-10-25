import Foundation

public extension Api {
    /// Returns a list of recent performance samples, in reverse slot order. Performance samples are taken every 60 seconds and include the number of transactions and slots that occur in a given time window.
    /// 
    /// - Parameters:
    ///   - limit: number of samples to return (maximum 720)
    ///   - onComplete: The result of an array PerformanceSample(numSlots: UInt64, numTransactions: UInt64, samplePeriodSecs: UInt slot: UInt64) 
    func getRecentPerformanceSamples(limit: UInt64, onComplete: @escaping(Result<[PerformanceSample], Error>) -> Void) {
        router.request(parameters: [limit]) { (result: Result<[PerformanceSample], Error>) in
            switch result {
            case .success(let samples):
                onComplete(.success(samples))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns a list of recent performance samples, in reverse slot order. Performance samples are taken every 60 seconds and include the number of transactions and slots that occur in a given time window.
    /// 
    /// - Parameters:
    ///   - limit: number of samples to return (maximum 720)
    /// - Returns: The result of an array PerformanceSample(numSlots: UInt64, numTransactions: UInt64, samplePeriodSecs: UInt slot: UInt64) 
    func getRecentPerformanceSamples(limit: UInt64) async throws -> [PerformanceSample] {
        try await withCheckedThrowingContinuation { c in
            self.getRecentPerformanceSamples(limit: limit, onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetRecentPerformanceSamples: ApiTemplate {
        public init(limit: UInt64) {
            self.limit = limit
        }

        public let limit: UInt64

        public typealias Success = [PerformanceSample]

        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getRecentPerformanceSamples(limit: limit, onComplete: completion)
        }
    }
}
