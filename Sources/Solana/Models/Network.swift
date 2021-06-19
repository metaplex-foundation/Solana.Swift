import Foundation

public enum Network: String, CaseIterable, Codable {
    case mainnetBeta = "mainnet-beta"
    case devnet = "devnet"
    case testnet = "testnet"

    public var cluster: String { rawValue }
}
