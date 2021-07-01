import Foundation

public extension Api {
    func getTokenAccountsByDelegate(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil, onComplete: @escaping (Result<[TokenAccount<AccountInfo>], Error>) -> Void) {
       
        var parameterMap = [String: String]()
        if let mint = mint {
            parameterMap["mint"] = mint
        } else if let programId =  programId {
            parameterMap["programId"] = programId
        } else {
            onComplete(Result.failure(SolanaError.other("mint or programId are mandatory parameters")))
            return
        }
        
        router.request(parameters: [pubkey, parameterMap, configs]) { (result: Result<Rpc<[TokenAccount<AccountInfo>]?>, Error>) in
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
