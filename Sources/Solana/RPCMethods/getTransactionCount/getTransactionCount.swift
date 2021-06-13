import Foundation

public extension Solana {
    func getTransactionCount(commitment: Commitment? = nil, onComplete: @escaping (Result<UInt64, Error>) -> ()){
        request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<UInt64, Error>) in
            switch result {
            case .success(let count):
                onComplete(.success(count))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
