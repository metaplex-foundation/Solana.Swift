import Foundation

public extension Api {
    /// Returns information about the current epoch
    /// 
    /// - Parameters:
    ///   - commitment: Configuration object
    ///   - onComplete: The result field will be an object with the following fields: (absoluteSlot: UInt64, blockHeight: UInt64, epoch: UInt64, slotIndex: UInt64, slotsInEpoch: UInt64)
    func getEpochInfo(commitment: Commitment? = nil, onComplete: @escaping ((Result<EpochInfo, Error>) -> Void)) {
        router.request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<EpochInfo, Error>) in
            switch result {
            case .success(let epoch):
                onComplete(.success(epoch))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns information about the current epoch
    /// 
    /// - Parameters:
    ///   - commitment: Configuration object
    /// - Returns: will be an object with the following fields: (absoluteSlot: UInt64, blockHeight: UInt64, epoch: UInt64, slotIndex: UInt64, slotsInEpoch: UInt64)
    func getEpochInfo(commitment: Commitment? = nil) async throws -> EpochInfo {
        try await withCheckedThrowingContinuation { c in
            self.getEpochInfo(commitment: commitment, onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetEpochInfo: ApiTemplate {
        public init(commitment: Commitment? = nil) {
            self.commitment = commitment
        }
        
        public let commitment: Commitment?
        
        public typealias Success = EpochInfo
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getEpochInfo(commitment: commitment, onComplete: completion)
        }
    }
}
