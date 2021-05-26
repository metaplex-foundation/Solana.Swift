//
//  TokenListsParser.swift
//  Alamofire
//
//  Created by Chung Tran on 22/04/2021.
//

import Foundation

public extension Solana {
    class TokensListParser {
        public init() {}
        public func parse(network: String) throws -> [Token] {
            // get json file
            let bundle = Bundle(for: TokensListParser.self)
            let path = bundle.path(forResource: network + ".tokens", ofType: "json")
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path!))

            // parse json
            var list = try JSONDecoder().decode(TokensList.self, from: jsonData)

            // map tags
            list.tokens = list.tokens.map {
                var item = $0
                item.tags = item._tags.map {
                    list.tags[$0] ?? TokenTag(name: $0, description: $0)
                }
                return item
            }

            // return list with mapped tags
            return list.tokens.reduce([Token]()) { (result, token) -> [Token] in
                var result = result
                if !result.contains(where: {$0.address == token.address}) {
                    result.append(token)
                }
                return result
            }
        }
    }
}
