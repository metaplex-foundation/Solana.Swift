import Foundation

public extension Api {
    func getSlotLeader(commitment: Commitment? = nil, onComplete: @escaping (Result<String, Error>) -> Void) {
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
