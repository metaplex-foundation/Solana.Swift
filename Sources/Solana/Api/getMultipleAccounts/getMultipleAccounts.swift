import Foundation

public extension Api {
    /// Returns the account information for a list of PublicKey.
    /// 
    /// - Parameters:
    ///   - pubkeys: An array of Pubkeys to query, as base-58 encoded strings (up to a maximum of 100).
    ///   - decodedTo: Object from which the data value will be mapped. Must be BufferLayout implementation
    ///   - onComplete: The result object of Arrays of BufferInfo<T>. Where T is the decodedTo object. 
    func getMultipleAccounts<T: BufferLayout>(pubkeys: [String],
                                              decodedTo: T.Type,
                                              onComplete: @escaping (Result<[BufferInfo<T>?], Error>) -> Void) {
        let configs = RequestConfiguration(encoding: "base64")
        router.request(parameters: [pubkeys, configs]) { (result: Result<Rpc<[BufferInfo<T>?]?>, Error>) in
            switch result {
            case .success(let rpc):
                guard let value = rpc.value else {
                    onComplete(.failure(SolanaError.nullValue))
                    return
                }
                onComplete(.success(value))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns the account information for a list of PublicKey.
    /// 
    /// - Parameters:
    ///   - pubkeys: An array of Pubkeys to query, as base-58 encoded strings (up to a maximum of 100).
    ///   - decodedTo: Object from which the data value will be mapped. Must be BufferLayout implementation
    /// - Returns: The result object of Arrays of BufferInfo<T>. Where T is the decodedTo object. 
    func getMultipleAccounts<T: BufferLayout>(pubkeys: [String], decodedTo: T.Type) async throws -> [BufferInfo<T>?] {
        try await withCheckedThrowingContinuation { c in
            self.getMultipleAccounts(pubkeys: pubkeys, decodedTo: decodedTo, onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetMultipleAccounts<T: BufferLayout>: ApiTemplate {
        public init(pubkeys: [String], decodedTo: T.Type) {
            self.pubkeys = pubkeys
            self.decodedTo = decodedTo
        }
        
        public let pubkeys: [String]
        public let decodedTo: T.Type
        
        public typealias Success = [BufferInfo<T>?]
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getMultipleAccounts(pubkeys: pubkeys, decodedTo: decodedTo.self, onComplete: completion)
        }
    }
}
