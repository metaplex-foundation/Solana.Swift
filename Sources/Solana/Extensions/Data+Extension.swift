import Foundation

extension Data {
  /// Two octet checksum as defined in RFC-4880. Sum of all octets, mod 65536
  public func checksum() -> UInt16 {
    let s = self.withUnsafeBytes { buf in
        return buf.lazy.map(UInt32.init).reduce(UInt32(0), +)
    }
    return UInt16(s % 65535)
  }
}

extension Data {
  public init(hex: String) {
    self.init([UInt8](hex: hex))
  }

  public var bytes: [UInt8] {
    Array(self)
  }

  public func toHexString() -> String {
    self.bytes.toHexString()
  }
}
