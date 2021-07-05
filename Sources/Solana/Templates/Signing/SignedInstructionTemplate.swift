//
//  SignedInstructionTemplate.swift
//  
//
//  Created by Nathan Lawrence on 7/4/21.
//

import Foundation

/**
 An `InstructionTemplate` protocol conformer, wrapped in a list of signatures.
 */
public struct SignedInstructionTemplate: SignedInstructionProvider {
    public let template: InstructionTemplate
    public let signers: [Account.Meta]

    internal init(instructionTemplate: InstructionTemplate, signers: [Account.Meta]) {
        self.template = instructionTemplate
        self.signers = signers
    }

    public var instructions: [TransactionInstruction] {
        [template.instruction(signedBy: signers)]
    }
}

extension InstructionTemplate {
    public func signed(by accountMeta: [Account.Meta]) -> SignedInstructionTemplate {
        SignedInstructionTemplate(instructionTemplate: self, signers: accountMeta)
    }
}

extension SignedInstructionTemplate {
    public func signed(by accountMeta: [Account.Meta]) -> SignedInstructionTemplate {
        SignedInstructionTemplate(instructionTemplate: self.template, signers: self.signers + accountMeta)
    }
}
