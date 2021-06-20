import Foundation

public extension Api {
    func minimumLedgerSlot(onComplete: @escaping (Result<UInt64, Error>) -> Void) {
        router.request { (result: Result<UInt64, Error>) in
            switch result {
            case .success(let slot):
                onComplete(.success(slot))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
