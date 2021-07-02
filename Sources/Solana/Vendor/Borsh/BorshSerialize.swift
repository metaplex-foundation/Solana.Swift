import Foundation

public protocol BorshSerializable {
  func serialize(to writer: inout Data) throws
}

extension UInt8: BorshSerializable {}
extension UInt16: BorshSerializable {}
extension UInt32: BorshSerializable {}
extension UInt64: BorshSerializable {}
extension UInt128: BorshSerializable {}
extension Int8: BorshSerializable {}
extension Int16: BorshSerializable {}
extension Int32: BorshSerializable {}
extension Int64: BorshSerializable {}
extension Int128: BorshSerializable {}

public extension FixedWidthInteger {
  func serialize(to writer: inout Data) throws {
    writer.append(contentsOf: withUnsafeBytes(of: self.littleEndian) { Array($0) })
  }
}

extension Float32: BorshSerializable {
  public func serialize(to writer: inout Data) throws {
    assert(!self.isNaN, "For portability reasons we do not allow to serialize NaNs.")
    var start = bitPattern.littleEndian
    writer.append(Data(buffer: UnsafeBufferPointer(start: &start, count: 1)))
  }
}

extension Float64: BorshSerializable {
  public func serialize(to writer: inout Data) throws {
    assert(!self.isNaN, "For portability reasons we do not allow to serialize NaNs.")
    var start = bitPattern.littleEndian
    writer.append(Data(buffer: UnsafeBufferPointer(start: &start, count: 1)))
  }
}

extension Bool: BorshSerializable {
  public func serialize(to writer: inout Data) throws {
    let intRepresentation: UInt8 = self ? 1 : 0
    try intRepresentation.serialize(to: &writer)
  }
}

extension Optional where Wrapped: BorshSerializable {
  func serialize(to writer: inout Data) throws {
    switch self {
    case .some(let value):
      try UInt8(1).serialize(to: &writer)
      try value.serialize(to: &writer)
    case .none:
      try UInt8(0).serialize(to: &writer)
    }
  }
}

extension String: BorshSerializable {
  public func serialize(to writer: inout Data) throws {
    let data = Data(utf8)
    try UInt32(data.count).serialize(to: &writer)
    writer.append(data)
  }
}

extension Array: BorshSerializable where Element: BorshSerializable {
  public func serialize(to writer: inout Data) throws {
    try UInt32(count).serialize(to: &writer)
    try forEach { try $0.serialize(to: &writer) }
  }
}

extension Set: BorshSerializable where Element: BorshSerializable & Comparable {
  public func serialize(to writer: inout Data) throws {
    try sorted().serialize(to: &writer)
  }
}

extension Dictionary: BorshSerializable where Key: BorshSerializable & Comparable, Value: BorshSerializable {
  public func serialize(to writer: inout Data) throws {
    let sortedByKeys = sorted(by: {$0.key < $1.key})
    try UInt32(sortedByKeys.count).serialize(to: &writer)
    try sortedByKeys.forEach { key, value in
      try key.serialize(to: &writer)
      try value.serialize(to: &writer)
    }
  }
}
