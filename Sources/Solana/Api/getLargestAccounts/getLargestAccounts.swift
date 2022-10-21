import Foundation

public extension Api {
    /// Returns the 20 largest accounts, by lamport balance (results may be cached up to two hours)
    /// - Parameter onComplete: The Result object of an array of LargestAccount (lamports: Lamports, address: String)
    func getLargestAccounts(onComplete: @escaping(Result<[LargestAccount], Error>) -> Void) {
        router.request { (result: Result<Rpc<[LargestAccount]?>, Error>) in
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
    /// Returns the 20 largest accounts, by lamport balance (results may be cached up to two hours)
    /// - Returns object of an array of LargestAccount (lamports: Lamports, address: String)
    func getLargestAccounts() async throws -> [LargestAccount] {
        try await withCheckedThrowingContinuation { c in
            self.getLargestAccounts(onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetLargestAccounts: ApiTemplate {
        public init() {}
        
        public typealias Success = [LargestAccount]
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getLargestAccounts(onComplete: completion)
        }
    }
}
