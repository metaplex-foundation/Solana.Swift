//
//  EmptyInfo.swift
//  SolanaSwift
//
//  Created by Chung Tran on 13/04/2021.
//

import Foundation

extension Solana {
    public struct EmptyInfo: BufferLayout {
        init() {}

        public init?(_ keys: [String: [UInt8]]) {
            self = EmptyInfo()
        }

        public static func layout() -> [(key: String?, length: Int)] {
            []
        }
    }
}
