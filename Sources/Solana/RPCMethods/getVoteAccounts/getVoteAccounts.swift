import Foundation

extension Solana {
    func getVoteAccounts(commitment: Commitment? = nil, onComplete: @escaping(Result<VoteAccounts, Error>)->()) {
        router.request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<VoteAccounts, Error>) in
            switch result {
            case .success(let accounts):
                onComplete(.success(accounts))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
