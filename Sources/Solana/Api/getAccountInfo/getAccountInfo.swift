import Foundation

public extension Api {

    /// Returns all information associated with the account of provided `PublicKey`
    /// 
    /// - Parameters:
    ///   - account: `PublicKey` of account to query, as base-58 encoded string
    ///   - onComplete: The result object of BufferInfoPureData of the account of provided `PublicKey`. Fails if empty
    func getAccountInfo(account: String, onComplete: @escaping (Result<BufferInfoPureData, Error>) -> Void) {
        let configs = RequestConfiguration(encoding: "base64")
        router.request(parameters: [account, configs]) { (result: Result<Rpc<BufferInfoPureData?>, Error>) in
            switch result {
            case let .success(rpc):
                guard let value = rpc.value else {
                    onComplete(.failure(SolanaError.nullValue))
                    return
                }
                onComplete(.success(value))
            case let .failure(error):
                onComplete(.failure(error))
            }
        }
    }

    /// Returns all information associated with the account of provided `PublicKey` parsed
    /// 
    /// - Parameters:
    ///   - account: `PublicKey` of account to query, as base-58 encoded string
    ///   - decodedTo: Object from which the data value will be mapped. Must be `BufferLayout` implementation
    ///   - onComplete: The result object of `BufferInfo<T>`. Where `T` is the decodedTo object. Fails if empty
    func getAccountInfo<T: BufferLayout>(account: String, decodedTo: T.Type, onComplete: @escaping (Result<BufferInfo<T>, Error>) -> Void) {
        let configs = RequestConfiguration(encoding: "base64")
        router.request(parameters: [account, configs]) { (result: Result<Rpc<BufferInfo<T>?>, Error>) in
            switch result {
            case let .success(rpc):
                guard let value = rpc.value else {
                    onComplete(.failure(SolanaError.nullValue))
                    return
                }
                onComplete(.success(value))
            case let .failure(error):
                onComplete(.failure(error))
            }
        }
    }

    /// Returns all information associated with the account of provided `PublicKey` parsed
    ///
    /// - Parameters:
    ///   - account: `PublicKey` of account to query, as base-58 encoded string
    ///   - decodedTo: Object from which the data value will be mapped. Must be `BufferLayout` implementation
    ///   - allowUnfundedRecipient: If the account is empty it will not return a failure
    ///   - onComplete: The result object of `BufferInfo<T>`. Where `T` is the decodedTo object.
    func getAccountInfo<T: BufferLayout>(account: String, decodedTo: T.Type, allowUnfundedRecipient: Bool = false, onComplete: @escaping (Result<BufferInfo<T>?, Error>) -> Void) {
        let configs = RequestConfiguration(encoding: "base64")
        router.request(parameters: [account, configs]) { (result: Result<Rpc<BufferInfo<T>?>, Error>) in
            switch result {
            case let .success(rpc):
                if allowUnfundedRecipient == false && rpc.value == nil {
                    onComplete(.failure(SolanaError.nullValue))
                    return
                }
                onComplete(.success(rpc.value))
            case let .failure(error):
                onComplete(.failure(error))
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns all information associated with the account of provided `PublicKey`
    /// 
    /// - Parameters:
    ///   - account: `PublicKey` of account to query, as base-58 encoded string
    /// - Returns: `BufferInfoPureData` of the account of provided `PublicKey`. Fails if empty
    func getAccountInfo<T: BufferLayout>(account: String, decodedTo: T.Type = T.self) async throws -> BufferInfo<T> {
        try await withCheckedThrowingContinuation { c in
            self.getAccountInfo(account: account, decodedTo: decodedTo, onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetAccountInfo<T: BufferLayout>: ApiTemplate {
        public init(account: String, decodedTo: T.Type) {
            self.account = account
            self.decodedTo = decodedTo
        }

        public let account: String
        public let decodedTo: T.Type

        public typealias Success = BufferInfo<T>

        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getAccountInfo(account: account, decodedTo: decodedTo.self, onComplete: completion)
        }
    }
}
