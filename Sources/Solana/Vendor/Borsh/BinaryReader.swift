import Foundation

public struct BinaryReader {
    var cursor: Int
    private let bytes: [UInt8]
    
    init(bytes: [UInt8]) {
        self.cursor = 0
        self.bytes = bytes
    }
}

extension BinaryReader {
    mutating func read(count: UInt32) -> [UInt8] {
        let newPosition = cursor + Int(count)
        let result = bytes[cursor..<newPosition]
        cursor = newPosition
        return Array(result)
    }
}
