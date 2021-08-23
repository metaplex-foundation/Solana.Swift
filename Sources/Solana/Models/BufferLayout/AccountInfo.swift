import Foundation

public struct AccountInfo: BufferLayout {
    public static let BUFFER_LENGTH: UInt64 = 165

    public let mint: PublicKey
    public let owner: PublicKey
    public let lamports: UInt64
    public let delegateOption: UInt32
    // swiftlint:disable all
    public var delegate: PublicKey?
    public let isInitialized: Bool
    public let isFrozen: Bool
    public let state: UInt8
    public let isNativeOption: UInt32
    public let rentExemptReserve: UInt64?
    public let isNativeRaw: UInt64
    public let isNative: Bool
    public var delegatedAmount: UInt64
    public let closeAuthorityOption: UInt32
    public var closeAuthority: PublicKey?
}

extension AccountInfo: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try mint.serialize(to: &writer)
        try owner.serialize(to: &writer)
        try lamports.serialize(to: &writer)
        try delegateOption.serialize(to: &writer)
        if let delegate = delegate {
            try delegate.serialize(to: &writer)
        } else {
            try PublicKey.NULL_PUBLICKEY_BYTES.forEach { try $0.serialize(to: &writer) }
        }
        try state.serialize(to: &writer)
        try isNativeOption.serialize(to: &writer)
        try isNativeRaw.serialize(to: &writer)
        try delegatedAmount.serialize(to: &writer)
        try closeAuthorityOption.serialize(to: &writer)
        if let closeAuthority = closeAuthority {
            try closeAuthority.serialize(to: &writer)
        } else {
            try PublicKey.NULL_PUBLICKEY_BYTES.forEach { try $0.serialize(to: &writer) }
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.mint = try .init(from: &reader)
        self.owner = try .init(from: &reader)
        self.lamports = try .init(from: &reader)
        self.delegateOption = try .init(from: &reader)
        let tempdelegate = try? PublicKey.init(from: &reader)
        self.state = try .init(from: &reader)
        self.isNativeOption = try .init(from: &reader)
        self.isNativeRaw = try .init(from: &reader)
        self.delegatedAmount = try .init(from: &reader)
        self.closeAuthorityOption = try .init(from: &reader)
        self.closeAuthority = try? PublicKey.init(from: &reader)
        
        if delegateOption == 0 {
            self.delegate = nil
            self.delegatedAmount = 0
        } else {
            self.delegate = tempdelegate
        }
        
        self.isInitialized = state != 0
        self.isFrozen = state == 2
        
        if isNativeOption == 1 {
            self.rentExemptReserve = isNativeRaw
            self.isNative = true
        } else {
            self.rentExemptReserve = nil
            isNative = false
        }
        
        if closeAuthorityOption == 0 {
            self.closeAuthority = nil
        }
    }    
}
