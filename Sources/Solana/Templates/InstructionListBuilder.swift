//
//  InstructionListBuilder.swift
//  
//
//  Created by Nathan Lawrence on 7/4/21.
//

import Foundation

@resultBuilder
public struct InstructionListBuilder {
    public static func buildBlock(_ components: SignedInstructionProvider...) -> SignedInstructionProvider {
        components.flatMap(\.instructions)
    }
}
