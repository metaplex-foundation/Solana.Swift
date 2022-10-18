import Foundation
import Beet

public struct TransactionInstruction: Decodable {
    public private(set) var keys: [AccountMeta]
    public let programId: PublicKey
    public let data: [UInt8]

    init(keys: [AccountMeta], programId: PublicKey, data: [BytesEncodable]) {
        self.keys = keys
        self.programId = programId
        self.data = data.bytes
    }

    public init(keys: [AccountMeta], programId: PublicKey, data: [UInt8]) {
        self.keys = keys
        self.programId = programId
        self.data = data
    }

    public mutating func append(_ key: AccountMeta) {
        keys.append(key)
    }

    public mutating func append(_ keys: [AccountMeta]) {
        self.keys.append(contentsOf: keys)
    }
}
