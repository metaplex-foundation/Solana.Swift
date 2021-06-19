import Foundation

extension Solana {
    public func getConfirmedSignaturesForAddress2(account: String, configs: RequestConfiguration? = nil, onComplete: @escaping (Result<[SignatureInfo], Error>) -> Void) {
        router.request(parameters: [account, configs]) { (result: Result<[SignatureInfo], Error>) in
            switch result {
            case .success(let signatures):
                onComplete(.success(signatures))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
