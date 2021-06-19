import Foundation

public extension Solana {
    func getSignatureStatuses(pubkeys: [String], configs: RequestConfiguration? = nil, onComplete: @escaping (Result<[SignatureStatus?], Error>) -> ()){
        router.request(parameters: [pubkeys, configs]) { (result: Result<Rpc<[SignatureStatus?]?>, Error>) in
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
