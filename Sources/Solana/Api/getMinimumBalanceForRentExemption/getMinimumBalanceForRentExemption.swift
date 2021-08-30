import Foundation

public extension Api {
    func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment? = "recent", onComplete: @escaping(Result<UInt64, Error>) -> Void) {
        router.request(parameters: [dataLength, RequestConfiguration(commitment: commitment)]) { (result: Result<UInt64, Error>) in
            switch result {
            case .success(let array):
                onComplete(.success(array))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

public extension ApiTemplates {
    struct GetMinimumBalanceForRentExemption: ApiTemplate {
        public init(dataLength: UInt64, commitment: Commitment? = nil) {
            self.dataLength = dataLength
            self.commitment = commitment
        }
        
        public let dataLength: UInt64
        public let commitment: Commitment?
        
        public typealias Success = UInt64
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getMinimumBalanceForRentExemption(dataLength: dataLength, commitment: commitment, onComplete: completion)
        }
    }
}
