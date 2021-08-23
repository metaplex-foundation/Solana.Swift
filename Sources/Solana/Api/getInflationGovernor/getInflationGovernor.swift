import Foundation

public extension Api {
    func getInflationGovernor(commitment: Commitment? = nil, onComplete: @escaping(Result<InflationGovernor, Error>) -> Void) {
        router.request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<InflationGovernor, Error>) in
            switch result {
            case .success(let governor):
                onComplete(.success(governor))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
