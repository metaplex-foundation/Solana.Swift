//
//  Transaction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation
import TweetNacl

public extension Solana {
    struct ConfirmedTransaction: Decodable {
        public let message: Message
        let signatures: [String]
    }
}

public extension Solana.ConfirmedTransaction {
    struct Message: Decodable {
        public let accountKeys: [Solana.Account.Meta]
        public let instructions: [Solana.ParsedInstruction]
        public let recentBlockhash: String
    }
}

public extension Solana {
    struct ParsedInstruction: Decodable {
        struct Parsed: Decodable {
            struct Info: Decodable {
                let owner: String?
                let account: String?
                let source: String?
                let destination: String?

                // create account
                let lamports: UInt64?
                let newAccount: String?
                let space: UInt64?

                // initialize account
                let mint: String?
                let rentSysvar: String?

                // approve
                let amount: String?
                let delegate: String?

                // transfer
                let authority: String?

                // transferChecked
                let tokenAmount: TokenAccountBalance?
            }
            let info: Info
            let type: String?
        }

        let program: String?
        let programId: String
        let parsed: Parsed?

        // swap
        public let data: String?
        let accounts: [String]?
    }
}
