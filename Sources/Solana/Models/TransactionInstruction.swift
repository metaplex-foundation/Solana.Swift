import Foundation

public struct TransactionInstruction: Decodable {
    public let keys: [Account.Meta]
    public let programId: PublicKey
    public let data: [UInt8]

    init(keys: [Account.Meta], programId: PublicKey, data: [BytesEncodable]) {
        self.keys = keys
        self.programId = programId
        self.data = data.bytes
    }
}
