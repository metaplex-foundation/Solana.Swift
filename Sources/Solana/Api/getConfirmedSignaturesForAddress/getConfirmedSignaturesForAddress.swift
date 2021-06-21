import Foundation

public extension Api {
    func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64, onComplete: @escaping (Result<[String], Error>) -> Void) {
        router.request(parameters: [account, startSlot, endSlot]) { (result: Result<[String], Error>) in
            switch result {
            case .success(let signatures):
                onComplete(.success(signatures))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
