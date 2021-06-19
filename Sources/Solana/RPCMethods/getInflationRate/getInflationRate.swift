import Foundation

extension Solana {
    func getInflationRate(onComplete: @escaping(Result<InflationRate, Error>)->()) {
        router.request() { (result: Result<InflationRate, Error>) in
            switch result {
            case .success(let rate):
                onComplete(.success(rate))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
