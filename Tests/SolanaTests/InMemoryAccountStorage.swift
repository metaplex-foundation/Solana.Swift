//
//  InMemoryAccountStorage.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import Foundation
@testable import Solana

extension Solana.Network {
    var testAccount: String {
        switch self {
        case .mainnetBeta:
            return "promote ignore inmate coast excess candy vanish erosion palm oxygen build powder"
        case .devnet:
            return "galaxy lend nose glow equip student way hockey step dismiss expect silent"
        default:
            fatalError("unsupported")
        }
    }
}

class InMemoryAccountStorage: SolanaAccountStorage {
    private var _account: Solana.Account?
    func save(_ account: Solana.Account) throws {
        _account = account
    }
    var account: Solana.Account? {
        _account
    }
    func clear() {
        _account = nil
    }
}
