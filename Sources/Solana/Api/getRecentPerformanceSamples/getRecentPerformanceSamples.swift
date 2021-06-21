import Foundation

public extension Api {
    func getRecentPerformanceSamples(limit: UInt64, onComplete: @escaping(Result<[PerformanceSample], Error>)->Void) {
        router.request(parameters: [limit]) { (result: Result<[PerformanceSample], Error>) in
            switch result {
            case .success(let samples):
                onComplete(.success(samples))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
