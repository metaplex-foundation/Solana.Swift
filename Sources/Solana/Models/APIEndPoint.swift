//
//  APIEndPoint.swift
//  SolanaSwift
//
//  Created by Chung Tran on 26/04/2021.
//

import Foundation

extension Solana {
    public struct APIEndPoint: Hashable, Codable {
        public init(url: String, network: Solana.Network, socketUrl: String? = nil) {
            self.url = url
            self.network = network
            self.socketUrl = socketUrl ?? url.replacingOccurrences(of: "http", with: "ws")
        }

        public let url: String
        public var network: Network
        public var socketUrl: String

        public static var definedEndpoints: [Self] {
            [
                .init(url: "https://solana-api.projectserum.com", network: .mainnetBeta),
                .init(url: "https://api.mainnet-beta.solana.com", network: .mainnetBeta),
                .init(url: "https://devnet.solana.com", network: .devnet),
                .init(url: "https://testnet.solana.com", network: .testnet)
            ]
        }
    }
}
