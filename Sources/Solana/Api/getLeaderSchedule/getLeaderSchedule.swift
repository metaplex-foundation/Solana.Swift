import Foundation

extension Api {
    public func getLeaderSchedule(epoch: UInt64? = nil, commitment: Commitment? = nil, onComplete: @escaping(Result<[String: [Int]]?, Error>)->Void) {
        router.request(parameters: [epoch, RequestConfiguration(commitment: commitment)]) { (result: Result<[String: [Int]]?, Error>) in
            switch result {
            case .success(let array):
                onComplete(.success(array))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
