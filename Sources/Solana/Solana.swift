import Foundation

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
    public let supportedTokens: [Token]

    public init(router: NetworkingRouter, accountStorage: SolanaAccountStorage) {
        self.router = router
        self.auth = accountStorage
        self.socket = SolanaSocket(endpoint: router.endpoint)
        self.supportedTokens = (try? TokensListParser().parse(network: router.endpoint.network.cluster).get()) ?? []
        self.api = Api(router: router, auth: accountStorage, supportedTokens: supportedTokens)
        self.action = Action(api: self.api, router: router, auth: accountStorage, supportedTokens: supportedTokens)
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

public class Action {
    internal let api: Api
    internal let router: NetworkingRouter
    internal let auth: SolanaAccountStorage
    internal let supportedTokens: [Token]

    public init(api: Api, router: NetworkingRouter, auth: SolanaAccountStorage, supportedTokens: [Token]) {
        self.router = router
        self.auth = auth
        self.supportedTokens = supportedTokens
        self.api = api
    }
}
