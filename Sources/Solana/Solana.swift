import Foundation

public protocol SolanaAccountStorage {
    func save(_ account: Account) -> Result<Void, Error>
    var account: Result<Account, Error> { get }
    func clear() -> Result<Void, Error>
}

public class Solana {
    let router: NetworkingRouter
    public let socket: SolanaSocket
    public let api: Api
    public let action: Action
    public let tokens: TokenInfoProvider

    public init(
        router: NetworkingRouter,
        tokenProvider: TokenInfoProvider = EmptyInfoTokenProvider()
    ) {
        self.router = router
        self.socket = SolanaSocket(endpoint: router.endpoint)
        self.tokens = tokenProvider
        self.api = Api(router: router, supportedTokens: self.tokens.supportedTokens)
        self.action = Action(api: self.api, router: router, supportedTokens: self.tokens.supportedTokens)
    }
}

public class Api {
    internal let router: NetworkingRouter
    internal let supportedTokens: [Token]

    public init(router: NetworkingRouter, supportedTokens: [Token]) {
        self.router = router
        self.supportedTokens = supportedTokens
    }
}

public class Action {
    internal let api: Api
    internal let router: SolanaRouter
    internal let supportedTokens: [Token]

    public init(api: Api, router: SolanaRouter, supportedTokens: [Token]) {
        self.router = router
        self.supportedTokens = supportedTokens
        self.api = api
    }
}
