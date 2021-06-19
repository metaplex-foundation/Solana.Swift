import Foundation

extension Solana {
    func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment? = "recent", onComplete: @escaping(Result<UInt64, Error>)->Void) {
        router.request(parameters: [dataLength, RequestConfiguration(commitment: commitment)]) { (result: Result<UInt64, Error>) in
            switch result {
            case .success(let array):
                onComplete(.success(array))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
