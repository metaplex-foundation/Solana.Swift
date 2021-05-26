//
//  AccountMeta+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 02/04/2021.
//

import Foundation

extension Array where Element == Solana.Account.Meta {
    func index(ofElementWithPublicKey publicKey: Solana.PublicKey) throws -> Int {
        guard let index = firstIndex(where: {$0.publicKey == publicKey})
        else {throw Solana.Error.other("Could not found accountIndex")}
        return index
    }
}
