//
//  TokenList.swift
//  Alamofire
//
//  Created by Chung Tran on 22/04/2021.
//

import Foundation

extension Solana {
    struct TokensList: Decodable {
        let name: String
        let logoURI: String
        let keywords: [String]
        let tags: [String: TokenTag]
        let timestamp: String
        var tokens: [Token]
    }

    public struct TokenTag: Hashable, Decodable {
        public var name: String
        public var description: String
    }

    public enum WrappingToken: String {
        case sollet, wormhole
    }

    public struct Token: Hashable, Decodable {
        public init(_tags: [String], chainId: Int, address: String, symbol: String, name: String, decimals: UInt8, logoURI: String?, tags: [TokenTag] = [], extensions: TokenExtensions?) {
            self._tags = _tags
            self.chainId = chainId
            self.address = address
            self.symbol = symbol
            self.name = name
            self.decimals = decimals
            self.logoURI = logoURI
            self.tags = tags
            self.extensions = extensions
        }

        let _tags: [String]

        public let chainId: Int
        public let address: String
        public let symbol: String
        public let name: String
        public let decimals: Decimals
        public let logoURI: String?
        public var tags: [TokenTag] = []
        public let extensions: TokenExtensions?

        enum CodingKeys: String, CodingKey {
            case chainId, address, symbol, name, decimals, logoURI, extensions, _tags = "tags"
        }

        public static func unsupported(
            mint: String?
        ) -> Token {
            Token(
                _tags: [],
                chainId: 101,
                address: mint ?? "<undefined>",
                symbol: "",
                name: mint ?? "<undefined>",
                decimals: 0,
                logoURI: nil,
                tags: [],
                extensions: nil
            )
        }

        public var wrappedBy: WrappingToken? {
            if tags.contains(where: {$0.name == "wrapped-sollet"}) {
                return .sollet
            }

            if tags.contains(where: {$0.name == "wrapped"}) &&
                tags.contains(where: {$0.name == "wormhole"}) {
                return .wormhole
            }

            return nil
        }
    }

    public struct TokenExtensions: Hashable, Decodable {
        public let website: String?
        public let bridgeContract: String?
    }
}
