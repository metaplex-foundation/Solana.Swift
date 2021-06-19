import Foundation

extension Solana {
    func getMultipleAccounts<T: BufferLayout>(pubkeys: [String],
                                              decodedTo: T.Type,
                                              onComplete: @escaping (Result<[BufferInfo<T>], Error>) -> ()) {
        let configs = RequestConfiguration(encoding: "base64")
        router.request(parameters: [pubkeys, configs]){ (result: Result<Rpc<[BufferInfo<T>]?>, Error>) in
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
