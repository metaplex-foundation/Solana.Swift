import Foundation

extension Solana {
    func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment? = nil, onComplete: @escaping(Result<String, Error>)->Void) {
        router.request(parameters: [account, lamports, RequestConfiguration(commitment: commitment)]) { (result: Result<String, Error>) in
            switch result {
            case .success(let hash):
                onComplete(.success(hash))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
