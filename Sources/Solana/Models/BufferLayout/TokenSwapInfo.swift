import Foundation

public struct TokenSwapInfo: BufferLayout, Equatable, Hashable, Encodable {
    public static var BUFFER_LENGTH: UInt64 = 324

    public let version: UInt8
    public let isInitialized: Bool
    public let nonce: UInt8
    public let tokenProgramId: PublicKey
    public var tokenAccountA: PublicKey
    public var tokenAccountB: PublicKey
    public let tokenPool: PublicKey
    public var mintA: PublicKey
    public var mintB: PublicKey
    public let feeAccount: PublicKey
    public let tradeFeeNumerator: UInt64
    public let tradeFeeDenominator: UInt64
    public let ownerTradeFeeNumerator: UInt64
    public let ownerTradeFeeDenominator: UInt64
    public let ownerWithdrawFeeNumerator: UInt64
    public let ownerWithdrawFeeDenominator: UInt64
    public let hostFeeNumerator: UInt64
    public let hostFeeDenominator: UInt64
    public let curveType: UInt8
    public let payer: PublicKey
}

extension TokenSwapInfo: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try version.serialize(to: &writer)
        if isInitialized { try UInt8(1).serialize(to: &writer) } else { try UInt8(0).serialize(to: &writer) }
        try nonce.serialize(to: &writer)
        try tokenProgramId.serialize(to: &writer)
        try tokenAccountA.serialize(to: &writer)
        try tokenAccountB.serialize(to: &writer)
        try tokenPool.serialize(to: &writer)
        try mintA.serialize(to: &writer)
        try mintB.serialize(to: &writer)
        try feeAccount.serialize(to: &writer)
        try tradeFeeNumerator.serialize(to: &writer)
        try tradeFeeDenominator.serialize(to: &writer)
        try ownerTradeFeeNumerator.serialize(to: &writer)
        try ownerTradeFeeDenominator.serialize(to: &writer)
        try ownerWithdrawFeeNumerator.serialize(to: &writer)
        try ownerWithdrawFeeDenominator.serialize(to: &writer)
        try hostFeeNumerator.serialize(to: &writer)
        try hostFeeDenominator.serialize(to: &writer)
        try curveType.serialize(to: &writer)
        try payer.serialize(to: &writer)
    }

    public init(from reader: inout BinaryReader) throws {
        self.version = try .init(from: &reader)
        self.isInitialized = try UInt8.init(from: &reader) == 1
        self.nonce = try .init(from: &reader)
        self.tokenProgramId = try PublicKey.init(from: &reader)
        self.tokenAccountA = try PublicKey.init(from: &reader)
        self.tokenAccountB = try PublicKey.init(from: &reader)
        self.tokenPool = try PublicKey.init(from: &reader)
        self.mintA = try PublicKey.init(from: &reader)
        self.mintB = try PublicKey.init(from: &reader)
        self.feeAccount = try PublicKey.init(from: &reader)
        self.tradeFeeNumerator = try .init(from: &reader)
        self.tradeFeeDenominator = try .init(from: &reader)
        self.ownerTradeFeeNumerator = try .init(from: &reader)
        self.ownerTradeFeeDenominator = try .init(from: &reader)
        self.ownerWithdrawFeeNumerator = try .init(from: &reader)
        self.ownerWithdrawFeeDenominator = try .init(from: &reader)
        self.hostFeeNumerator = try .init(from: &reader)
        self.hostFeeDenominator = try .init(from: &reader)
        self.curveType = try .init(from: &reader)
        self.payer = try PublicKey.init(from: &reader)
    }
}
