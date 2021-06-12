import Foundation

public extension Solana {
    func getBlockCommitment(block: UInt64, onComplete: @escaping(Result<BlockCommitment, Error>) -> ()){
        request(parameters: [block]) { (result: Result<BlockCommitment, Error>) in
            switch result {
            case .success(let blockCommitment):
                onComplete(.success(blockCommitment))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
