import Foundation

public struct Mint: BufferLayout, Equatable, Hashable, Encodable {
    public static var BUFFER_LENGTH: UInt64 = 82

    public let mintAuthorityOption: UInt32
    public let mintAuthority: PublicKey?
    public let supply: UInt64
    public let decimals: UInt8
    public let isInitialized: Bool
    public let freezeAuthorityOption: UInt32
    public let freezeAuthority: PublicKey?
}

extension Mint: BorshCodable {
    public init(from reader: inout BinaryReader) throws {
        self.mintAuthorityOption = try .init(from: &reader)
        self.mintAuthority = try? PublicKey.init(from: &reader)
        self.supply = try .init(from: &reader)
        self.decimals = try .init(from: &reader)
        self.isInitialized = try UInt8.init(from: &reader) == 1
        self.freezeAuthorityOption = try .init(from: &reader)
        let freezeAuthorityTemp = try? PublicKey.init(from: &reader)
        if freezeAuthorityOption == 0 {
            self.freezeAuthority = nil
        } else {
            self.freezeAuthority = freezeAuthorityTemp
        }
    }

    public func serialize(to writer: inout Data) throws {
        try mintAuthorityOption.serialize(to: &writer)
        if let mintAuthority = mintAuthority {
            try mintAuthority.serialize(to: &writer)
        } else {
            try PublicKey.NULL_PUBLICKEY_BYTES.forEach { try $0.serialize(to: &writer) }
        }
        try supply.serialize(to: &writer)
        try decimals.serialize(to: &writer)
        if isInitialized { try UInt8(1).serialize(to: &writer) } else { try UInt8(0).serialize(to: &writer) }
        try freezeAuthorityOption.serialize(to: &writer)
        if let freezeAuthority = freezeAuthority {
            try freezeAuthority.serialize(to: &writer)
        } else {
            try PublicKey.NULL_PUBLICKEY_BYTES.forEach { try $0.serialize(to: &writer) }
        }
    }
}
