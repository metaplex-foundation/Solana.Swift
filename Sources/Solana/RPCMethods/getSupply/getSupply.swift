import Foundation

extension Solana {
    func getSupply(commitment: Commitment? = nil, onComplete: @escaping(Result<Supply, Error>)->()) {
        router.request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<Rpc<Supply?>, Error>) in
            switch result {
            case .success(let rpc):
                guard let value = rpc.value else {
                    onComplete(.failure(SolanaError.nullValue))
                    return
                }
                onComplete(.success(value))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
