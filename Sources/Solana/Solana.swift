import Foundation
import Combine

public protocol SolanaAccountStorage {
    func save(_ account: Account) -> Result<Void, Error>
    var account: Result<Account, Error> { get }
    func clear() -> Result<Void, Error>
}

public class Solana {
    let router: NetworkingRouter
    public let socket: SolanaSocket
    public let auth: SolanaAccountStorage
    public let api: Api
    public let action: Action
    public let tokens: TokenInfoProvider

    public init(
        router: NetworkingRouter,
        accountStorage: SolanaAccountStorage,
        tokenProvider: TokenInfoProvider = EmptyInfoTokenProvider()
    ) {
        self.router = router
        self.auth = accountStorage
        self.socket = SolanaSocket(endpoint: router.endpoint)
        self.tokens = tokenProvider
        self.api = Api(router: router, auth: accountStorage, supportedTokens: self.tokens.supportedTokens)
        self.action = Action(api: self.api, router: router, auth: accountStorage, supportedTokens: self.tokens.supportedTokens)
    }
}

public class Api {
    internal let router: NetworkingRouter
    internal let auth: SolanaAccountStorage
    internal let supportedTokens: [Token]

    public init(router: NetworkingRouter, auth: SolanaAccountStorage, supportedTokens: [Token]) {
        self.router = router
        self.auth = auth
        self.supportedTokens = supportedTokens
    }
}

extension Api {
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    public func perform<T: ApiTemplate>(_ apiTemplate: T) async throws -> T.Success {
        try await withCheckedThrowingContinuation { continuation in
            perform(apiTemplate) { continuation.resume(with: $0)}
        }
    }
    @available(iOS 13.0.0, *)
    @available(macOS 10.15.0, *)
    func publisher<T: ApiTemplate>(for apiTemplate: T) -> AnyPublisher<T.Success, Error> {
             Future<T.Success, Error> { promise in
                 self.perform(apiTemplate) { promise($0) }
             }.eraseToAnyPublisher()
     }
}

public class Action {
    internal let api: Api
    internal let router: SolanaRouter
    internal let auth: SolanaAccountStorage
    internal let supportedTokens: [Token]

    public init(api: Api, router: SolanaRouter, auth: SolanaAccountStorage, supportedTokens: [Token]) {
        self.router = router
        self.auth = auth
        self.supportedTokens = supportedTokens
        self.api = api
    }
}

extension Action {
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    public func perform<T: ActionTemplate>(_ actionTemplate: T) async throws -> T.Success {
        try await withCheckedThrowingContinuation { continuation in
            perform(actionTemplate) { continuation.resume(with: $0)}
        }
    }
    @available(iOS 13.0.0, *)
    @available(macOS 10.15.0, *)
    func publisher<T: ActionTemplate>(for actionTemplate: T) -> AnyPublisher<T.Success, Error> {
             Future<T.Success, Error> { promise in
                 self.perform(actionTemplate) { promise($0) }
             }.eraseToAnyPublisher()
     }
}
