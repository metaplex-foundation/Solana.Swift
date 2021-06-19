import Foundation

extension Solana {
    func getFirstAvailableBlock(onComplete: @escaping (Result<UInt64, Error>)->()) {
        router.request() { (result:Result<UInt64, Error>) in
            switch result {
            case .success(let block):
                onComplete(.success(block))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
