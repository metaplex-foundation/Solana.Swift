import Foundation

public extension Solana {
    @available(*, deprecated, message: "Use getBlock insted")
    func getConfirmedBlocks(startSlot: UInt64, endSlot: UInt64, onComplete:@escaping (Result<[UInt64], Error>) -> Void) {
        router.request(parameters: [startSlot, endSlot]) { (result: Result<[UInt64], Error>) in
            switch result {
            case .success(let confirmedBlocks):
                onComplete(.success(confirmedBlocks))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
