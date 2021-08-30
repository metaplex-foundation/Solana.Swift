import Foundation
import XCTest
import Solana

enum TokensListParserError: Error {
    case invalidData
    case canNotDecode
}

public class TokensListParser {
    public init() {}
    public func parse(network: String) -> Result<[Token], Error> {
        // get json file
        let jsonData = getFileFrom("TokenInfo/\(network).tokens")
        // parse json
        guard var list = try? JSONDecoder().decode(TokensList.self, from: jsonData) else {
            return .failure(TokensListParserError.canNotDecode)
        }

        // map tags
        list.tokens = list.tokens.map {
            var item = $0
            item.tags = item._tags.map {
                return try! list.tags[$0] ?? TokenTag(name: $0, description: $0)
            }
            return item
        }

        // return list with mapped tags
        let listTokens =  list.tokens.reduce([Token]()) { (result, token) -> [Token] in
            var result = result
            if !result.contains(where: {$0.address == token.address}) {
                result.append(token)
            }
            return result
        }
        return .success(listTokens)
    }
}

func getFileFrom(_ filename: String) -> Data {
    @objc class SolanaTests: NSObject { }
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    let resourceURL = thisDirectory.appendingPathComponent("../Resources/\(filename).json")
    return try! Data(contentsOf: resourceURL)
}

public struct TokensList: Decodable {
    let name: String
    let logoURI: String
    let keywords: [String]
    let tags: [String: TokenTag]
    let timestamp: String
    var tokens: [Token]
}
