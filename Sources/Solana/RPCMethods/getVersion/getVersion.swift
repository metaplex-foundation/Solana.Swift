import Foundation

extension Solana {
    func getVersion(onComplete: @escaping(Result<Version, Error>)->Void) {
        router.request { (result: Result<Version, Error>) in
            switch result {
            case .success(let version):
                onComplete(.success(version))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
