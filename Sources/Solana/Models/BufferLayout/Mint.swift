import Foundation

public struct Mint: BufferLayout, Equatable, Hashable, Encodable {
    init(mintAuthorityOption: UInt32, mintAuthority: PublicKey?, supply: UInt64, decimals: UInt8, isInitialized: Bool, freezeAuthorityOption: UInt32, freezeAuthority: PublicKey?) {
        self.mintAuthorityOption = mintAuthorityOption
        self.mintAuthority = mintAuthority
        self.supply = supply
        self.decimals = decimals
        self.isInitialized = isInitialized
        self.freezeAuthorityOption = freezeAuthorityOption
        self.freezeAuthority = freezeAuthority
    }
    
    public let mintAuthorityOption: UInt32
    public let mintAuthority: PublicKey?
    public let supply: UInt64
    public let decimals: UInt8
    public let isInitialized: Bool
    public let freezeAuthorityOption: UInt32
    public let freezeAuthority: PublicKey?
    public init?(_ keys: [String: [UInt8]]) {
        guard let mintAuthorityOption = keys["mintAuthorityOption"]?.toUInt32(),
              let mintAuthority = PublicKey(bytes: keys["mintAuthority"]),
              let supply = keys["supply"]?.toUInt64(),
              let decimals = keys["decimals"]?.first,
              let isInitialized = keys["decimals"]?.first,
              let freezeAuthorityOption = keys["freezeAuthorityOption"]?.toUInt32(),
              let freezeAuthority = PublicKey(bytes: keys["freezeAuthority"])
        else {return nil}
        self.mintAuthorityOption = mintAuthorityOption
        if mintAuthorityOption == 0 {
            self.mintAuthority = nil
        } else {
            self.mintAuthority = mintAuthority
        }
        
        self.supply = supply
        self.decimals = decimals
        self.isInitialized = isInitialized != 0
        self.freezeAuthorityOption = freezeAuthorityOption
        if freezeAuthorityOption == 0 {
            self.freezeAuthority = nil
        } else {
            self.freezeAuthority = freezeAuthority
        }
    }
    
    public static func layout()  -> [(key: String?, length: Int)] {
        [
            (key: "mintAuthorityOption", length: 4), // 4
            (key: "mintAuthority", length: PublicKey.LENGTH), // 36
            (key: "supply", length: 8), // 44
            (key: "decimals", length: 1), // 45
            (key: "isInitialized", length: 1), // 46
            (key: "freezeAuthorityOption", length: 4), // 50
            (key: "freezeAuthority", length: PublicKey.LENGTH) // 82
        ]
    }
}

extension Mint: BorshCodable{
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
