import Foundation

public extension Api {
    func getAccountInfo<T: BufferLayout>(account: PublicKey, decodedTo: T.Type, onComplete: @escaping(Result<BufferInfo<T>, Error>) -> Void) {
        let configs = RequestConfiguration(encoding: "base64")
        router.request(parameters: [account.base58EncodedString, configs]) {  (result: Result<Rpc<BufferInfo<T>?>, Error>) in
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
