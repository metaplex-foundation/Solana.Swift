//
//  MintLayout.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/11/2020.
//

import Foundation

extension Solana {
    public struct Mint: BufferLayout, Equatable, Hashable, Encodable {
        init(mintAuthorityOption: UInt32, mintAuthority: Solana.PublicKey?, supply: UInt64, decimals: UInt8, isInitialized: Bool, freezeAuthorityOption: UInt32, freezeAuthority: Solana.PublicKey?) {
            self.mintAuthorityOption = mintAuthorityOption
            self.mintAuthority = mintAuthority
            self.supply = supply
            self.decimals = decimals
            self.isInitialized = isInitialized
            self.freezeAuthorityOption = freezeAuthorityOption
            self.freezeAuthority = freezeAuthority
        }

        public let mintAuthorityOption: UInt32
        public let mintAuthority: PublicKey?
        public let supply: UInt64
        public let decimals: UInt8
        public let isInitialized: Bool
        public let freezeAuthorityOption: UInt32
        public let freezeAuthority: PublicKey?
        public init?(_ keys: [String: [UInt8]]) {
            guard let mintAuthorityOption = keys["mintAuthorityOption"]?.toUInt32(),
                let mintAuthority = try? PublicKey(bytes: keys["mintAuthority"]),
                let supply = keys["supply"]?.toUInt64(),
                let decimals = keys["decimals"]?.first,
                let isInitialized = keys["decimals"]?.first,
                let freezeAuthorityOption = keys["freezeAuthorityOption"]?.toUInt32(),
                let freezeAuthority = try? PublicKey(bytes: keys["freezeAuthority"])
            else {return nil}
            self.mintAuthorityOption = mintAuthorityOption
            if mintAuthorityOption == 0 {
                self.mintAuthority = nil
            } else {
                self.mintAuthority = mintAuthority
            }

            self.supply = supply
            self.decimals = decimals
            self.isInitialized = isInitialized != 0
            self.freezeAuthorityOption = freezeAuthorityOption
            if freezeAuthorityOption == 0 {
                self.freezeAuthority = nil
            } else {
                self.freezeAuthority = freezeAuthority
            }
        }

        public static func layout()  -> [(key: String?, length: Int)] {
            [
                (key: "mintAuthorityOption", length: 4),
                (key: "mintAuthority", length: PublicKey.LENGTH),
                (key: "supply", length: 8),
                (key: "decimals", length: 1),
                (key: "isInitialized", length: 1),
                (key: "freezeAuthorityOption", length: 4),
                (key: "freezeAuthority", length: PublicKey.LENGTH)
            ]
        }
    }
}
