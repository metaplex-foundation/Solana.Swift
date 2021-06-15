import Foundation

public protocol SolanaAccountStorage {
    func save(_ account: Solana.Account) throws
    var account: Solana.Account? {get}
    func clear()
}

public class Solana {
    let endpoint: RpcApiEndPoint
    public let accountStorage: SolanaAccountStorage
    public private(set) var supportedTokens = [Token]()

    public init(endpoint: RpcApiEndPoint, accountStorage: SolanaAccountStorage) {
        self.endpoint = endpoint
        self.accountStorage = accountStorage

        let parser = TokensListParser()
        supportedTokens = (try? parser.parse(network: endpoint.network.cluster)) ?? []
    }
}
