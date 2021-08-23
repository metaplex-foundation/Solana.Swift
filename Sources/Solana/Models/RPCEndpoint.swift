import Foundation

public struct RPCEndpoint: Hashable, Codable {
    public let url: URL
    public let urlWebSocket: URL
    public let network: Network
    public init(url: URL, urlWebSocket: URL, network: Network) {
        self.url = url
        self.urlWebSocket = urlWebSocket
        self.network = network
    }

    public static let mainnetBetaSerum = RPCEndpoint(url: URL(string: "https://solana-api.projectserum.com")!, urlWebSocket: URL(string: "wss://solana-api.projectserum.com")!, network: .mainnetBeta)
    public static let mainnetBetaSolana = RPCEndpoint(url: URL(string: "https://api.mainnet-beta.solana.com")!, urlWebSocket: URL(string: "wss://api.mainnet-beta.solana.com")!, network: .mainnetBeta)
    public static let devnetSolana = RPCEndpoint(url: URL(string: "https://api.devnet.solana.com")!, urlWebSocket: URL(string: "wss://api.devnet.solana.com")!, network: .devnet)
    public static let testnetSolana = RPCEndpoint(url: URL(string: "https://testnet.solana.com")!, urlWebSocket: URL(string: "wss://testnet.solana.com")!, network: .testnet)
}
