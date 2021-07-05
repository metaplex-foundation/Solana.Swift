import Foundation

public extension Array where Element == UInt8 {
    func toUInt32() -> UInt32? {
        guard let data = Data(self).withUnsafeBytes({ ptr ->  UnsafePointer<UInt32>? in
            guard let typedPointer = ptr.baseAddress?.assumingMemoryBound(to: UInt32.self) else {
                return nil
            }
            return typedPointer
        }) else { return nil }
        return UInt32(littleEndian: data.pointee)
    }

    func toUInt64() -> UInt64? {
        guard let data = Data(self).withUnsafeBytes({ ptr ->  UnsafePointer<UInt64>? in
            guard let typedPointer = ptr.baseAddress?.assumingMemoryBound(to: UInt64.self) else {
                return nil
            }
            return typedPointer
        }) else { return nil }
        return UInt64(littleEndian: data.pointee)
    }

    func toInt() -> Int {
        var value: Int = 0
        for byte in self {
            value = value << 8
            value = value | Int(byte)
        }
        return value
    }
}
