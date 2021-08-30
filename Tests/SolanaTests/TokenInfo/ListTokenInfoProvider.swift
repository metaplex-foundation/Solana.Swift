import Foundation
import XCTest
import Solana

public class ListTokenInfoProvider: TokenInfoProvider {
    private let endpoint: RPCEndpoint
    public init(endpoint: RPCEndpoint) {
        self.endpoint = endpoint
    }
    
    lazy public var supportedTokens: [Token] = {
        return (try? TokensListParser().parse(network: endpoint.network.cluster).get()) ?? []
    }()
}
