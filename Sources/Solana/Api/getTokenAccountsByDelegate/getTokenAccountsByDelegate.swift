import Foundation

public extension Api {
    func getTokenAccountsByDelegate(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil, onComplete: @escaping (Result<[TokenAccount<AccountInfo>], Error>) -> Void) {
        router.request(parameters: [pubkey, mint, programId, configs]) { (result: Result<Rpc<[TokenAccount<AccountInfo>]?>, Error>) in
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
