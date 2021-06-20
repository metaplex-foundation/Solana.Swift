import Foundation

public extension Api {
    func getSlot(commitment: Commitment? = nil, onComplete: @escaping (Result<UInt64, Error>) -> Void) {
        router.request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<UInt64, Error>) in
            switch result {
            case .success(let slot):
                onComplete(.success(slot))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
