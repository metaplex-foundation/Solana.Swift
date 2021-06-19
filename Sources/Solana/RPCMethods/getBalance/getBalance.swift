import Foundation

public extension Solana {
    func getBalance(account: String? = nil, commitment: Commitment? = nil, onComplete: @escaping(Result<UInt64, Error>) -> ()) {
        
        guard let account = account ?? accountStorage.account?.publicKey.base58EncodedString
        else {
            onComplete(.failure(SolanaError.unauthorized))
            return
        }
        router.request(parameters: [account, RequestConfiguration(commitment: commitment)]) { (result: Result<Rpc<UInt64?>, Error>) in
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
