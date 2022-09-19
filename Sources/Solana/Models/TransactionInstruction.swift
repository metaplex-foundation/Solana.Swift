import Foundation
import Beet

public struct TransactionInstruction: Decodable {
    public let keys: [AccountMeta]
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
}
