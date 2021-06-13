import Foundation

public extension Solana {
    func getStakeActivation(stakeAccount: String, configs: RequestConfiguration? = nil, onComplete: @escaping (Result<StakeActivation, Error>) -> ()){
        request(parameters: [stakeAccount, configs]) { (result: Result<StakeActivation, Error>) in
            switch result {
            case .success(let hash):
                onComplete(.success(hash))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
