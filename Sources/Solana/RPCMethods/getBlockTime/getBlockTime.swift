import Foundation

extension Solana {
    func getBlockTime(block: UInt64, onComplete: @escaping( (Result<Date?, Error>) -> ())) {
        router.request(parameters:  [block]) { (result: Result<Int64?, Error>) in
            switch result {
            case .success(let timestamp):
                guard let timestamp = timestamp else {
                    onComplete(.success(nil))
                    return
                }
                onComplete(.success(Date(timeIntervalSince1970: TimeInterval(timestamp))))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
