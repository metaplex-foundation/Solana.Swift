import Foundation

public extension Api {
    func getFirstAvailableBlock(onComplete: @escaping (Result<UInt64, Error>) -> Void) {
        router.request { (result: Result<UInt64, Error>) in
            switch result {
            case .success(let block):
                onComplete(.success(block))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
