import Foundation

public struct EmptyInfo: BufferLayout {
    init() {}
    
    public init?(_ keys: [String: [UInt8]]) {
        self = EmptyInfo()
    }
    
    public static func layout() -> [(key: String?, length: Int)] {
        []
    }
}

extension EmptyInfo: BorshCodable {
    public init(from reader: inout BinaryReader) throws { }
    public func serialize(to writer: inout Data) throws { }
}
