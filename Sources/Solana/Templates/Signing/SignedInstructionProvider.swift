//
//  SignedInstructionProvider.swift
//  
//
//  Created by Nathan Lawrence on 7/4/21.
//

import Foundation

/**
 An object that hands over `TransactionInstruction` objects based on its own context.
 */
public protocol SignedInstructionProvider {
    var instructions: [TransactionInstruction]  { get }
}

extension Array: SignedInstructionProvider
    where Element: SignedInstructionProvider {
        public var instructions: [TransactionInstruction] {
            self.flatMap(\.instructions)
        }
}

extension TransactionInstruction: SignedInstructionProvider {
    public var instructions: [TransactionInstruction] {
        [self]
    }
}
