import Foundation

public extension Api {
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

public extension ApiTemplates {
    struct GetConfirmedBlock: ApiTemplate {
        public init(slot: UInt64, encoding: String = "json") {
            self.slot = slot
            self.encoding = encoding
        }
        
        public let slot: UInt64
        public let encoding: String
        
        public typealias Success = ConfirmedBlock
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getConfirmedBlock(slot: slot, encoding: encoding, onComplete: completion)
        }
    }
}
