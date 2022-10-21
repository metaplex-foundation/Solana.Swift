import Foundation

public extension Api {
    /// Returns all accounts owned by the provided program Pubkey parsed
    ///
    /// - Parameters:
    ///   - publicKey: Pubkey of program, as base-58 encoded string
    ///   - configs: Configuration object containing 
    ///   - decodedTo: Object from which the data value will be mapped. Must be BufferLayout implementation
    ///   - onComplete: The result object of Arrays of ProgramAccount<T>. Where T is the decodedTo object. 
    func getProgramAccounts<T: BufferLayout>(
        publicKey: String,
        configs: RequestConfiguration? = RequestConfiguration(encoding: "base64"),
        decodedTo: T.Type,
        onComplete: @escaping (Result<[ProgramAccount<T>], Error>) -> Void
    ) {
        router.request(parameters: [publicKey, configs]) { (result: Result<[ProgramAccount<T>], Error>) in
            switch result {
            case .success(let programs):
                onComplete(.success(programs))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
    /// Returns all accounts owned by the provided program Pubkey
    ///
    /// - Parameters:
    ///   - publicKey: Pubkey of program, as base-58 encoded string
    ///   - configs: Configuration object containing 
    ///   - onComplete: The result object of Arrays of ProgramAccountPureData(which is ProgramAccount<Data>).
    func getProgramAccounts(
        publicKey: String,
        configs: RequestConfiguration? = RequestConfiguration(encoding: "base64"),
        onComplete: @escaping (Result<[ProgramAccountPureData], Error>) -> Void
    ) {
        router.request(parameters: [publicKey, configs]) { (result: Result<[ProgramAccountPureData], Error>) in
            switch result {
            case .success(let programs):
                onComplete(.success(programs))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns all accounts owned by the provided program Pubkey parsed
    ///
    /// - Parameters:
    ///   - publicKey: Pubkey of program, as base-58 encoded string
    ///   - configs: Configuration object containing 
    ///   - decodedTo: Object from which the data value will be mapped. Must be BufferLayout implementation
    /// - Returns: Arrays of ProgramAccount<T>. Where T is the decodedTo object. 
    func getProgramAccounts<T: BufferLayout>(
        publicKey: String,
        configs: RequestConfiguration? = RequestConfiguration(encoding: "base64"),
        decodedTo: T.Type = T.self
    ) async throws -> [ProgramAccount<T>] {
        try await withCheckedThrowingContinuation { c in
            self.getProgramAccounts(
                publicKey: publicKey,
                configs: configs,
                decodedTo: decodedTo,
                onComplete: c.resume(with:)
            )
        }
    }

    /// Returns all accounts owned by the provided program Pubkey
    ///
    /// - Parameters:
    ///   - publicKey: Pubkey of program, as base-58 encoded string
    ///   - configs: Configuration object containing 
    /// - Returns: Arrays of ProgramAccountPureData(which is ProgramAccount<Data>).
    func getProgramAccounts(
        publicKey: String,
        configs: RequestConfiguration? = RequestConfiguration(encoding: "base64")
    ) async throws -> [ProgramAccountPureData] {
        try await withCheckedThrowingContinuation { c in
            self.getProgramAccounts(publicKey: publicKey, configs: configs, onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetProgramAccounts<T: BufferLayout>: ApiTemplate {
        public init(publicKey: String, configs: RequestConfiguration? = RequestConfiguration(encoding: "base64"), decodedTo: T.Type) {
            self.publicKey = publicKey
            self.configs = configs
            self.decodedTo = decodedTo
        }
        
        public let publicKey: String
        public let configs: RequestConfiguration?
        public let decodedTo: T.Type
        
        public typealias Success = [ProgramAccount<T>]
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getProgramAccounts(publicKey: publicKey, configs: configs, decodedTo: decodedTo.self, onComplete: completion)
        }
    }
}
