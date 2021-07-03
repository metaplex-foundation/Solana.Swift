import Foundation
import RxSwift
import Solana

public extension Api {
    func getEpochSchedule() -> Single<EpochSchedule> {
        Single.create { emitter in
            self.getEpochSchedule {
                switch $0 {
                case .success(let epochSheadule):
                    emitter(.success(epochSheadule))
                case .failure(let error):
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
