import Foundation

extension Solana {
    public struct TransactionInstruction: Decodable {
        public let keys: [Solana.Account.Meta]
        public let programId: Solana.PublicKey
        public let data: [UInt8]
        
        init(keys: [Solana.Account.Meta], programId: Solana.PublicKey, data: [BytesEncodable]) {
            self.keys = keys
            self.programId = programId
            self.data = data.bytes
        }
    }
}
