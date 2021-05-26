//
//  SolanaSDK+Notifications.swift
//  SolanaSwift
//
//  Created by Chung Tran on 03/12/2020.
//

import Foundation

public extension Solana {
    struct Notification {
        public typealias Account = Rpc<Solana.BufferInfo<AccountInfo>>
        public struct Signature: Decodable {
            let err: ResponseError?
        }
    }
}
