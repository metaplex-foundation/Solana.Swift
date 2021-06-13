//
//  Error.swift
//  p2p_wallet
//
//  Created by Chung Tran on 10/26/20.
//

import Foundation

public extension Solana {
    enum SolanaError: Error {
        case unauthorized
        case notFoundProgramAddress
        case invalidRequest(reason: String? = nil)
        case invalidResponse(ResponseError)
        case socket(Error)
        case couldNotRetriveAccountInfo
        case other(String)
    }
}
