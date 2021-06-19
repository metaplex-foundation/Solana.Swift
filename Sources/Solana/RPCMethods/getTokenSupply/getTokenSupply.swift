import Foundation

public extension Solana {
    func getTokenSupply(pubkey: String, commitment: Commitment? = nil, onComplete: @escaping (Result<TokenAmount, Error>) -> ()){
        router.request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) { (result: Result<Rpc<TokenAmount?>, Error>) in
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
