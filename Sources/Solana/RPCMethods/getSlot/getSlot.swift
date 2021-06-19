import Foundation

public extension Solana {
    func getSlot(commitment: Commitment? = nil, onComplete: @escaping (Result<UInt64, Error>) -> ()){
        router.request(parameters: [RequestConfiguration(commitment: commitment)]){ (result: Result<UInt64, Error>) in
            switch result {
            case .success(let slot):
                onComplete(.success(slot))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
