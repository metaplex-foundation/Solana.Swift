import Foundation

public protocol TokenInfoProvider {
    var supportedTokens: [Token] { get }
}

public class EmptyInfoTokenProvider: TokenInfoProvider {
    public var supportedTokens: [Token] = []
    public init(){}
}
