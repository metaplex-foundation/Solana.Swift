import Foundation

public extension Solana {
    func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64, onComplete: @escaping (Result<[UInt64], Error>) -> Void) {
        router.request(parameters: [startSlot, limit]) { (result: Result<[UInt64], Error>) in
            switch result {
            case .success(let confirmedBlocks):
                onComplete(.success(confirmedBlocks))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
