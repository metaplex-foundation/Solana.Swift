import Foundation

public protocol TokenInfoProvider {
    var supportedTokens: [Token] { get }
}

public class EmptyInfoTokenProvider: TokenInfoProvider {
    public var supportedTokens: [Token] = []
    public init() {}
}

enum TokenListProviderError: Error {
    case couldNotReadFile
    case couldNotParseList
}

public class TokenListProvider: TokenInfoProvider {
    public var supportedTokens: [Token] = []
    public init(path: URL) throws {
        guard let jsonFile = try? String(contentsOf: path) else {
            throw TokenListProviderError.couldNotReadFile
        }
        guard let data = jsonFile.data(using: .utf8),
              let tokenList = try? JSONDecoder().decode(TokensList.self, from: data) else {
            throw TokenListProviderError.couldNotParseList
        }
        supportedTokens = tokenList.tokens
    }
}

public struct TokenTag: Decodable {
    public let name: String
    public let description: String
    public init(name: String, description: String) throws {
        self.name = name
        self.description = description
    }
}

public struct TokensList: Decodable {
    let name: String
    let logoURI: String
    let keywords: [String]
    let tags: [String: TokenTag]
    let timestamp: String
    var tokens: [Token]
}
