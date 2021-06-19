import Foundation

extension Solana {
    func getEpochSchedule(onComplete: @escaping (Result<EpochSchedule, Error>) -> Void) {
        router.request { (result: Result<EpochSchedule, Error>) in
            switch result {
            case .success(let epochSheadule):
                onComplete(.success(epochSheadule))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
