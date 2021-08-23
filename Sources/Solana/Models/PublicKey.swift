import Foundation

public struct PublicKey {
    public static let NULL_PUBLICKEY_BYTES: [UInt8] = Array(repeating: UInt8(0), count: LENGTH)
    public static let LENGTH = 32
    public let bytes: [UInt8]

    public init?(bytes: [UInt8]?) {
        guard let bytes = bytes, bytes.count <= PublicKey.LENGTH else {
            return nil
        }
        self.bytes = bytes
    }

    public init?(string: String) {
        guard string.utf8.count >= PublicKey.LENGTH else {
            return nil
        }
        self.init(bytes: Base58.decode(string))
    }

    public init?(data: Data) {
        guard data.count <= PublicKey.LENGTH else {
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

extension PublicKey: Equatable, CustomStringConvertible, Hashable {
    public var description: String {
        base58EncodedString
    }
}

public extension PublicKey {
    enum PublicKeyError: Error {
        case invalidPublicKey
    }
}

extension PublicKey: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(base58EncodedString)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard string.utf8.count >= PublicKey.LENGTH else {
            throw PublicKeyError.invalidPublicKey
        }
        self.bytes = Base58.decode(string)
    }
}

extension PublicKey: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try bytes.forEach { try $0.serialize(to: &writer) }
    }

    public init(from reader: inout BinaryReader) throws {
        let byteArray = try Array(0..<PublicKey.LENGTH).map { _ in try UInt8.init(from: &reader) }
        self.bytes = byteArray
    }
}
