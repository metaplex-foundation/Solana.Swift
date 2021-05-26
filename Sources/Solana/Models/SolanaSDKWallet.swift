//
//  Wallet.swift
//  SolanaSwift
//
//  Created by Chung Tran on 22/04/2021.
//

import Foundation

extension Solana {
    public struct Wallet: Hashable {
        // MARK: - Properties
        public var pubkey: String?
        public var lamports: UInt64?
        public var token: Token
        public var userInfo: AnyHashable?

        let liquidity: Bool?
        public var isLiquidity: Bool {
            liquidity == true
        }

        // MARK: - Initializer
        public init(pubkey: String? = nil, lamports: UInt64? = nil, token: Solana.Token, liquidity: Bool? = false) {
            self.pubkey = pubkey
            self.lamports = lamports
            self.token = token
            self.liquidity = liquidity
        }

        // MARK: - Computed properties
        public var amount: Double? {
            lamports?.convertToBalance(decimals: token.decimals)
        }

        public func shortPubkey(numOfSymbolsRevealed: Int = 4) -> String {
            guard let pubkey = pubkey else {return ""}
            return pubkey.prefix(numOfSymbolsRevealed) + "..." + pubkey.suffix(numOfSymbolsRevealed)
        }

        // MARK: - Fabric methods
        public static func nativeSolana(
            pubkey: String?,
            lamport: UInt64?
        ) -> Wallet {
            Wallet(
                pubkey: pubkey,
                lamports: lamport,
                token: .init(
                    _tags: [],
                    chainId: 101,
                    address: "So11111111111111111111111111111111111111112",
                    symbol: "SOL",
                    name: "Solana",
                    decimals: 9,
                    logoURI: nil,
                    tags: [],
                    extensions: nil
                ),
                liquidity: false
            )
        }
    }
}
