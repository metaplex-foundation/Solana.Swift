import Foundation

public extension Api {
    func getBlockCommitment(block: UInt64, onComplete: @escaping(Result<BlockCommitment, Error>) -> Void) {
        router.request(parameters: [block]) { (result: Result<BlockCommitment, Error>) in
            switch result {
            case .success(let blockCommitment):
                onComplete(.success(blockCommitment))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

public extension ApiTemplates {
    struct GetBlockCommitment: ApiTemplate {
        public init(block: UInt64) {
            self.block = block
        }
        
        public let block: UInt64
        
        public typealias Success = BlockCommitment
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getBlockCommitment(block: block, onComplete: completion)
        }
    }
}
