//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 2021/08/29.
//

import Foundation

public protocol TokenInfoProvider {
    var supportedTokens: [Token] { get }
}

class EmptyToken: TokenInfoProvider {
    var supportedTokens: [Token] = []
}

class ListTokenProvider: TokenInfoProvider {
    private let endpoint: RPCEndpoint
    init(endpoint: RPCEndpoint) {
        self.endpoint = endpoint
    }
    
    lazy var supportedTokens: [Token] = {
        return (try? TokensListParser().parse(network: endpoint.network.cluster).get()) ?? []
    }()
}
