import Foundation

public extension Solana {
    func getFeeCalculatorForBlockhash(blockhash: String, commitment: Commitment? = nil, onComplete: @escaping (Result<Fee, Error>) -> Void) {
        router.request(parameters: [blockhash, RequestConfiguration(commitment: commitment)]) { (result: Result<Rpc<Fee?>, Error>) in
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
