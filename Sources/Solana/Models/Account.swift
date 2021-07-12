import Foundation
import TweetNacl

public struct Account: Codable, Hashable {
    public let phrase: [String]
    public let publicKey: PublicKey
    public let secretKey: Data
    
    public init?(phrase: [String] = [], network: Network, derivablePath: DerivablePath? = nil) {
        let mnemonic: Mnemonic
        var phrase = phrase.filter {!$0.isEmpty}
        if !phrase.isEmpty,
           let newMnemonic = Mnemonic(phrase: phrase) {
            mnemonic = newMnemonic
        } else {
            mnemonic = Mnemonic()
            phrase = mnemonic.phrase
        }
        self.phrase = phrase
        
        let derivablePath = derivablePath ?? .default
        
        switch derivablePath.type {
        default:
            guard let keys = try? Ed25519HDKey.derivePath(derivablePath.rawValue, seed: mnemonic.seed.toHexString()).get() else {
                return nil
            }
            
            guard let keyPair = try? NaclSign.KeyPair.keyPair(fromSeed: keys.key) else {
                return nil
            }
            guard let newKey = PublicKey(data: keyPair.publicKey) else {
                return nil
            }
            self.publicKey = newKey
            self.secretKey = keyPair.secretKey
        }
    }
    
    public init?(secretKey: Data) {
        guard let keys = try? NaclSign.KeyPair.keyPair(fromSecretKey: secretKey) else {
            return nil
        }
        guard let newKey = PublicKey(data: keys.publicKey) else {
            return  nil
        }
        guard let phrase = try? Mnemonic.toMnemonic(secretKey.bytes).get() else {
            return  nil
        }
        self.publicKey = newKey
        self.secretKey = keys.secretKey
        
        self.phrase = phrase
    }
}

public extension Account {
    struct Meta: Decodable, CustomDebugStringConvertible {
        public let publicKey: PublicKey
        public var isSigner: Bool
        public var isWritable: Bool
        
        // MARK: - Decodable
        enum CodingKeys: String, CodingKey {
            case pubkey, signer, writable
        }
        
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            guard let newKey = PublicKey(string: try values.decode(String.self, forKey: .pubkey)) else {
                throw SolanaError.invalidPublicKey
            }
            publicKey = newKey
            isSigner = try values.decode(Bool.self, forKey: .signer)
            isWritable = try values.decode(Bool.self, forKey: .writable)
        }
        
        // Initializers
        public init(publicKey: PublicKey, isSigner: Bool, isWritable: Bool) {
            self.publicKey = publicKey
            self.isSigner = isSigner
            self.isWritable = isWritable
        }
        
        public var debugDescription: String {
            "{\"publicKey\": \"\(publicKey.base58EncodedString)\", \"isSigner\": \(isSigner), \"isWritable\": \(isWritable)}"
        }
    }
}
