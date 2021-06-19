import Foundation

public protocol SolanaAccountStorage {
    func save(_ account: Account) -> Result<Void, Error>
    var account: Account? { get }
    func clear() -> Result<Void, Error>
}

public class Solana {
    let router: NetworkingRouter
    public let accountStorage: SolanaAccountStorage
    public private(set) var supportedTokens = [Token]()

    public init(router: NetworkingRouter, accountStorage: SolanaAccountStorage) {
        self.router = router
        self.accountStorage = accountStorage
        let parser = TokensListParser()
        supportedTokens = (try? parser.parse(network: router.endpoint.network.cluster)) ?? []
    }
}
