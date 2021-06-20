import Foundation

public extension Api {
    func getStakeActivation(stakeAccount: String, configs: RequestConfiguration? = nil, onComplete: @escaping (Result<StakeActivation, Error>) -> Void) {
        router.request(parameters: [stakeAccount, configs]) { (result: Result<StakeActivation, Error>) in
            switch result {
            case .success(let hash):
                onComplete(.success(hash))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
