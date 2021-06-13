import Foundation

extension Solana {
    public struct RpcApiEndPoint: Hashable, Codable {
        public let url: URL
        public let network: Network
        public init(url: URL, network: Solana.Network) {
            self.url = url
            self.network = network
        }
        
        public static let mainnetBetaSerum = RpcApiEndPoint(url: URL(string: "https://solana-api.projectserum.com")!, network: .mainnetBeta)
        public static let mainnetBetaSolana = RpcApiEndPoint(url: URL(string: "https://api.mainnet-beta.solana.com")!, network: .mainnetBeta)
        public static let devnetSolana = RpcApiEndPoint(url: URL(string: "https://api.devnet.solana.com")!, network: .devnet)
        public static let testnetSolana = RpcApiEndPoint(url: URL(string: "https://testnet.solana.com")!, network: .testnet)
    }
}
