import Foundation

public extension Solana {
    @available(*, deprecated, message: "Use getBlock insted")
    func getConfirmedBlock(slot: UInt64, encoding: String = "json", onComplete: @escaping(Result<ConfirmedBlock, Error>) -> Void) {
        router.request(parameters: [slot, encoding]) { (result: Result<ConfirmedBlock, Error>)  in
            switch result {
            case .success(let confirmedBlock):
                onComplete(.success(confirmedBlock))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
