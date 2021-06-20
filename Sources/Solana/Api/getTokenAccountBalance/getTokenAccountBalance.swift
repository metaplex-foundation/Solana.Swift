import Foundation

public extension Api {
    func getTokenAccountBalance(pubkey: String, commitment: Commitment? = nil, onComplete: @escaping (Result<TokenAccountBalance, Error>) -> Void) {
        router.request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) { (result: Result<Rpc<TokenAccountBalance?>, Error>) in
            switch result {
            case .success(let rpc):
                guard let value = rpc.value else {
                    onComplete(.failure(SolanaError.nullValue))
                    return
                }
                guard UInt64(value.amount) != nil else {
                    onComplete(.failure(SolanaError.couldNotRetriveBalance))
                    return
                }
                onComplete(.success(value))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
