//
//  Error.swift
//  p2p_wallet
//
//  Created by Chung Tran on 10/26/20.
//

import Foundation

public extension Solana {
    enum Error: Swift.Error, Equatable {
        public static func == (lhs: Solana.Error, rhs: Solana.Error) -> Bool {
            switch (lhs, rhs) {
            case (.unauthorized, .unauthorized):
                return true
            case (.notFound, .notFound):
                return true
            case (.invalidRequest(let rs1), .invalidRequest(let rs2)):
                return rs1 == rs2
            case (.invalidResponse(let rs1), .invalidResponse(let rs2)):
                return rs1.code == rs2.code
            case (.socket(let er1), .socket(let er2)):
                return er1.localizedDescription == er2.localizedDescription
            case (.other(let rs1), .other(let rs2)):
                return rs1 == rs2
            case (.unknown, .unknown):
                return true
            default:
                return false
            }
        }

        case unauthorized
        case notFound

        // Invalid Requests
        case invalidRequest(reason: String? = nil)

        // Invalid responses
        case invalidResponse(ResponseError)

        // Socket error
        case socket(Swift.Error)

        // Other
        case other(String)
        case unknown
    }
}
