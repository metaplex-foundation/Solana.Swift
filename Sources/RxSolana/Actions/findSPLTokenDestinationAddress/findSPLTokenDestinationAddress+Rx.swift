import Foundation
import RxSwift
import Solana

extension Action {
    public func findSPLTokenDestinationAddress(
        mintAddress: String,
        destinationAddress: String
    ) -> Single<SPLTokenDestinationAddress> {
        Single.create { emitter in
            self.findSPLTokenDestinationAddress(mintAddress: mintAddress, destinationAddress: destinationAddress) {
                switch $0 {
                case .success(let address):
                    emitter(.success(address))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
