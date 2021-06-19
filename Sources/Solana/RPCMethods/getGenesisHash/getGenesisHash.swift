import Foundation

extension Solana {
    func getGenesisHash(onComplete: @escaping(Result<String, Error>)->()) {
        router.request() { (result:Result<String, Error>) in
            switch result {
            case .success(let hash):
                onComplete(.success(hash))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
