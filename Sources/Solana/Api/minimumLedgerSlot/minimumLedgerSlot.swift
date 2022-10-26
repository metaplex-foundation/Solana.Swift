import Foundation

public extension Api {
    /// Returns the lowest slot that the node has information about in its ledger.
    ///  This value may increase over time if the node is configured to purge older ledger data
    /// 
    /// - Parameter onComplete: Minimum ledger slot UInt64
    func minimumLedgerSlot(onComplete: @escaping (Result<UInt64, Error>) -> Void) {
        router.request { (result: Result<UInt64, Error>) in
            switch result {
            case .success(let slot):
                onComplete(.success(slot))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns the lowest slot that the node has information about in its ledger.
    ///  This value may increase over time if the node is configured to purge older ledger data
    /// 
    /// - Returns: Minimum ledger slot UInt64
    func minimumLedgerSlot() async throws -> UInt64 {
        try await withCheckedThrowingContinuation { c in
            self.minimumLedgerSlot(onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct MinimumLedgerSlot: ApiTemplate {
        public init() {}

        public typealias Success = UInt64

        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.minimumLedgerSlot(onComplete: completion)
        }
    }
}
