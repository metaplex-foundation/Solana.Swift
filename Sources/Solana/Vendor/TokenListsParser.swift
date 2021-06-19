import Foundation

enum TokensListParserError: Error {
    case invalidData
    case canNotDecode
}

public class TokensListParser {
    public init() {}
    public func parse(network: String) -> Result<[Token], Error> {
        // get json file
        let path = Bundle.module.url(forResource: network + ".tokens", withExtension: "json")?.path
        
        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path!)) else {
            return .failure(TokensListParserError.invalidData)
        }

        // parse json
        guard var list = try? JSONDecoder().decode(TokensList.self, from: jsonData) else {
            return .failure(TokensListParserError.canNotDecode)
        }

        // map tags
        list.tokens = list.tokens.map {
            var item = $0
            item.tags = item._tags.map {
                list.tags[$0] ?? TokenTag(name: $0, description: $0)
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
