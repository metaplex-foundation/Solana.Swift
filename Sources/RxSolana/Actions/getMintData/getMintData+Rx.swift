import Foundation
import RxSwift
import Solana

public extension Action {

    func getMintData(mintAddress: PublicKey, programId: PublicKey = .tokenProgramId) -> Single<Mint> {
        Single.create { emitter in
            self.getMintData(mintAddress: mintAddress, programId: programId) { result in
                switch result {
                case .success(let mint):
                    return emitter(.success(mint))
                case .failure(let error):
                    return emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func getMultipleMintDatas(mintAddresses: [PublicKey], programId: PublicKey = .tokenProgramId) -> Single<[PublicKey: Mint]> {
        Single.create { emitter in
            self.getMultipleMintDatas(mintAddresses: mintAddresses, programId: programId) { result in
                switch result {
                case .success(let mint):
                    return emitter(.success(mint))
                case .failure(let error):
                    return emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
