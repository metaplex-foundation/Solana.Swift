import Foundation

extension Solana {
    func simulateTransaction(transaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!, onComplete: @escaping(Result<TransactionStatus, Error>)->()) {
        router.request(parameters: [transaction, configs]) { (result:Result<Rpc<TransactionStatus?>, Error>) in
            switch result {
            case .success(let rpc):
                guard let value = rpc.value else {
                    onComplete(.failure(SolanaError.nullValue))
                    return
                }
                onComplete(.success(value))
                return
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }
    }
}
