import Foundation

public protocol SolanaAccountStorage {
    func save(_ account: Account) -> Result<Void, Error>
    var account: Result<Account, Error> { get }
    func clear() -> Result<Void, Error>
}

public class Solana {
    let router: NetworkingRouter
    public let auth: SolanaAccountStorage
    public let supportedTokens: [Token]

    public init(router: NetworkingRouter, accountStorage: SolanaAccountStorage) {
        self.router = router
        self.auth = accountStorage
        self.supportedTokens = (try? TokensListParser().parse(network: router.endpoint.network.cluster).get()) ?? []
    }
}
