import Foundation

public extension Api {
    /// Returns the slot of the lowest confirmed block that has not been purged from the ledger
    /// 
    /// - Parameter onComplete: Result Object of UInt64 which is the slot number
    func getFirstAvailableBlock(onComplete: @escaping (Result<UInt64, Error>) -> Void) {
        router.request { (result: Result<UInt64, Error>) in
            switch result {
            case .success(let block):
                onComplete(.success(block))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
     /// Returns the slot of the lowest confirmed block that has not been purged from the ledger
    /// 
    /// - Returns: Result Object of UInt64 which is the slot number
    func getFirstAvailableBlock() async throws -> UInt64 {
        try await withCheckedThrowingContinuation { c in
            self.getFirstAvailableBlock(onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetFirstAvailableBlock: ApiTemplate {
        public init() {}

        public typealias Success = UInt64

        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getFirstAvailableBlock(onComplete: completion)
        }
    }
}
