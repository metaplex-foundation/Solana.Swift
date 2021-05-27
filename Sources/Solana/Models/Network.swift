//
//  Network.swift
//  SolanaSwift
//
//  Created by Chung Tran on 26/01/2021.
//

import Foundation

extension Solana {
    public enum Network: String, CaseIterable, Codable {
        case mainnetBeta = "mainnet-beta"
        case devnet = "devnet"
        case testnet = "testnet"

        public var cluster: String {rawValue}
    }
}
