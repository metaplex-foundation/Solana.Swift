import Foundation

public protocol SolanaAccountStorage {
    func save(_ account: Account) -> Result<Void, Error>
    var account: Account? { get }
    func clear() -> Result<Void, Error>
}

public class Solana {
    let router: NetworkingRouter
    public let accountStorage: SolanaAccountStorage
    public let supportedTokens: [Token]

    public init(router: NetworkingRouter, accountStorage: SolanaAccountStorage) {
        self.router = router
        self.accountStorage = accountStorage
        self.supportedTokens = (try? TokensListParser().parse(network: router.endpoint.network.cluster).get()) ?? []
    }
}
