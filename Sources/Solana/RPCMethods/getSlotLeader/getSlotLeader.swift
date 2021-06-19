import Foundation

public extension Solana {
    func getSlotLeader(commitment: Commitment? = nil, onComplete: @escaping (Result<String, Error>) -> ()){
        router.request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<String, Error>) in
            switch result {
            case .success(let hash):
                onComplete(.success(hash))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
