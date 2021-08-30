import Foundation

public extension Api {
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

public extension ApiTemplates {
    struct GetEpochSchedule: ApiTemplate {
        public init() {}
        
        public typealias Success = EpochSchedule
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getEpochSchedule(onComplete: completion)
        }
    }
}
