import Foundation

public extension Solana {
    func minimumLedgerSlot(onComplete: @escaping (Result<UInt64, Error>) -> ()){
        router.request(){ (result: Result<UInt64, Error>) in
            switch result {
            case .success(let slot):
                onComplete(.success(slot))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
