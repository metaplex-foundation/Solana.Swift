import Foundation

public extension Solana {
    func getAccountInfo<T: BufferLayout>(account: String, decodedTo: T.Type, onComplete: @escaping(Result<BufferInfo<T>, Error>) -> ()) {
        let configs = RequestConfiguration(encoding: "base64")
        request(parameters: [account, configs]) {  (result: Result<Rpc<BufferInfo<T>?>, Error>) in
            switch result{
            case .success(let rpc):
                guard let value = rpc.value else {
                    onComplete(.failure(SolanaError.couldNotRetriveAccountInfo))
                    return
                }
                onComplete(.success(value))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

