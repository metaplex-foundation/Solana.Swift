import Foundation

extension Solana {
    func getEpochInfo(commitment: Commitment? = nil, onComplete: @escaping ((Result<EpochInfo, Error>) -> ())) {
        request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<EpochInfo, Error>) in
            switch result {
            case .success(let epoch):
                onComplete(.success(epoch))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
