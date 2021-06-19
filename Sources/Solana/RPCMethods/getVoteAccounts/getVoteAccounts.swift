import Foundation

extension Solana {
    public func getVoteAccounts(commitment: Commitment? = nil, onComplete: @escaping(Result<VoteAccounts, Error>)->Void) {
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
