import Foundation

public extension Api {
    func getGenesisHash(onComplete: @escaping(Result<String, Error>) -> Void) {
        router.request { (result: Result<String, Error>) in
            switch result {
            case .success(let hash):
                onComplete(.success(hash))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
