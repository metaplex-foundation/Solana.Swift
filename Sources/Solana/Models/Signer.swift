import Foundation
import TweetNacl

@available(*, deprecated, renamed: "Signer")
typealias Account = Signer

public protocol Signer {
    var publicKey: PublicKey { get }
    func sign(serializedMessage: Data) throws -> Data
}

public struct HotAccount: Codable, Hashable, Signer {
    public let phrase: [String]
    public let publicKey: PublicKey
    public let secretKey: Data

    public func sign(serializedMessage: Data) throws -> Data {
        let data = try NaclSign.signDetached(message: serializedMessage, secretKey: secretKey)
        return data
    }

    public init?(phrase: [String] = [], derivablePath: DerivablePath? = nil) {
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
        case .bip32Deprecated:
            guard let keychain = try? Keychain(seedString: phrase.joined(separator: " "))  else {
                return nil
            }
            guard let seed = try? keychain.derivedKeychain(at: derivablePath.rawValue).privateKey else {
                            return nil
            }
            guard let keyPair = try? NaclSign.KeyPair.keyPair(fromSeed: seed) else {
                return nil
            }
            guard let newKey = PublicKey(data: keyPair.publicKey) else {
                return nil
            }
            self.publicKey = newKey
            self.secretKey = keyPair.secretKey
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

public struct AccountMeta: Decodable, CustomDebugStringConvertible {
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
