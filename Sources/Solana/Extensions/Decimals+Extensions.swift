//
//  Decimals+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 06/04/2021.
//

import Foundation

extension Solana.Decimals {
    static var SOL: Solana.Decimals { 9 }
}

extension Solana {
    public var solDecimals: Solana.Decimals {
        supportedTokens.first(where: {$0.symbol == "SOL"})?.decimals ?? 9
    }
}
