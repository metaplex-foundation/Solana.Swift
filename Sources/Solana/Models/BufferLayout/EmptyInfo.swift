import Foundation

public struct EmptyInfo: BufferLayout {
    public static var BUFFER_LENGTH: UInt64 = 0
}

extension EmptyInfo: BorshCodable {
    public init(from reader: inout BinaryReader) throws { }
    public func serialize(to writer: inout Data) throws { }
}
