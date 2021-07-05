//
//  InstructionTemplate.swift
//  
//
//  Created by Nathan Lawrence on 7/4/21.
//

import Foundation

/**
 An object that generates a `TransactionInstruction` using its own context and a provided, ordered list of signers.
 */
public protocol InstructionTemplate {
    func instruction(signedBy accounts: [Account.Meta]) -> TransactionInstruction
}
