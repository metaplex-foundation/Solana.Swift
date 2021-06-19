import Foundation

extension Solana {
    func getIdentity(onComplete: @escaping(Result<Identity, Error>)->()) {
        router.request() { (result:Result<Identity, Error>) in
            switch result {
            case .success(let identity):
                onComplete(.success(identity))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
