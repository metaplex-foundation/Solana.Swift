//
//  TransactionTemplate.swift
//  
//
//  Created by Nathan Lawrence on 7/4/21.
//

import Foundation

public protocol TransactionTemplate {
    @InstructionListBuilder
    var instructions: SignedInstructionProvider  { get }

    var signatures: [Transaction.Signature] { get }
}

public extension TransactionTemplate {
    func transaction(with feePayer: PublicKey,
                     recentBlockhash: String) ->  Transaction {

        let instructionList = instructions

        return Transaction(signatures: signatures,
                           feePayer: feePayer,
                           instructions: instructionList.instructions,
                           recentBlockhash: recentBlockhash)
    }
}
