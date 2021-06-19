import Foundation

public extension Solana {
    struct PublicKey {

        public static let LENGTH = 32
        public let bytes: [UInt8]

        init?(bytes: [UInt8]?) {
            guard let bytes = bytes, bytes.count <= PublicKey.LENGTH else {
                return nil
            }
            self.bytes = bytes
        }

        init?(string: String) {
            guard string.utf8.count >= Solana.PublicKey.LENGTH else {
                return nil
            }
            self.init(bytes: Base58.decode(string))
        }

        init?(data: Data) {
            guard data.count <= Solana.PublicKey.LENGTH else {
                return nil
            }
            self.init(bytes: [UInt8](data))
        }

        public var base58EncodedString: String {
            Base58.encode(bytes)
        }

        public var data: Data {
            Data(bytes)
        }

        public func short(numOfSymbolsRevealed: Int = 4) -> String {
            let pubkey = base58EncodedString
            return pubkey.prefix(numOfSymbolsRevealed) + "..." + pubkey.suffix(numOfSymbolsRevealed)
        }
    }
}

extension Solana.PublicKey: Equatable, CustomStringConvertible, Hashable {
    public var description: String {
        base58EncodedString
    }
}

public extension Solana.PublicKey {
    enum PublicKeyError: Error {
        case invalidPublicKey
    }
}

extension Solana.PublicKey: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(base58EncodedString)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard string.utf8.count >= Solana.PublicKey.LENGTH else {
            throw PublicKeyError.invalidPublicKey
        }
        self.bytes = Base58.decode(string)
    }
}
