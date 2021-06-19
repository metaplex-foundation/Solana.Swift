import Foundation

protocol BytesEncodable {
    var bytes: [UInt8] {get}
}

extension UInt8: BytesEncodable {
    var bytes: [UInt8] { [self] }
}

extension UInt64: BytesEncodable {}

extension UInt32: BytesEncodable {}

extension PublicKey: BytesEncodable {}

extension Data: BytesEncodable {}

extension Bool: BytesEncodable {
    var bytes: [UInt8] {self ? [UInt8(1)]: [UInt8(0)]}
}

extension Array: BytesEncodable where Element == BytesEncodable {
    var bytes: [UInt8] {reduce([], {$0 + $1.bytes})}
}

extension RawRepresentable where RawValue == UInt32 {
    var bytes: [UInt8] {rawValue.bytes}
}

extension RawRepresentable where RawValue == UInt8 {
    var bytes: [UInt8] {rawValue.bytes}
}
