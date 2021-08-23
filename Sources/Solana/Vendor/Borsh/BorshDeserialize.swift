import Foundation

public protocol BorshDeserializable {
  init(from reader: inout BinaryReader) throws
}

enum DeserializationError: Error {
  case noData
}

public extension FixedWidthInteger {
  init(from reader: inout BinaryReader) throws {
    var value: Self = .zero
    let bytes = reader.read(count: UInt32(MemoryLayout<Self>.size))
    let size = withUnsafeMutableBytes(of: &value, { bytes.copyBytes(to: $0) })
    assert(size == MemoryLayout<Self>.size)
    self = Self(littleEndian: value)
  }
}

extension UInt8: BorshDeserializable {}
extension UInt16: BorshDeserializable {}
extension UInt32: BorshDeserializable {}
extension UInt64: BorshDeserializable {}
extension UInt128: BorshDeserializable {}
extension Int8: BorshDeserializable {}
extension Int16: BorshDeserializable {}
extension Int32: BorshDeserializable {}
extension Int64: BorshDeserializable {}
extension Int128: BorshDeserializable {}

extension Float32: BorshDeserializable {
  public init(from reader: inout BinaryReader) throws {
    var value: Self = .zero
    let bytes = reader.read(count: UInt32(MemoryLayout<Self>.size))
    let size = withUnsafeMutableBytes(of: &value, { bytes.copyBytes(to: $0) })
    assert(size == MemoryLayout<Self>.size)
    assert(!value.isNaN, "For portability reasons we do not allow to deserialize NaNs.")
    self = value
  }
}

extension Float64: BorshDeserializable {
  public init(from reader: inout BinaryReader) throws {
    var value: Self = .zero
    let bytes = reader.read(count: UInt32(MemoryLayout<Self>.size))
    let size = withUnsafeMutableBytes(of: &value, { bytes.copyBytes(to: $0) })
    assert(size == MemoryLayout<Self>.size)
    assert(!value.isNaN, "For portability reasons we do not allow to deserialize NaNs.")
    self = value
  }
}

extension Bool: BorshDeserializable {
  public init(from reader: inout BinaryReader) throws {
    var value: Self = false
    let bytes = reader.read(count: UInt32(MemoryLayout<Self>.size))
    let size = withUnsafeMutableBytes(of: &value, { bytes.copyBytes(to: $0) })
    assert(size == MemoryLayout<Self>.size)
    self = value
  }
}

extension Optional where Wrapped: BorshDeserializable {
  init(from reader: inout BinaryReader) throws {
    let isSomeValue: UInt8 = try .init(from: &reader)
    switch isSomeValue {
    case 1: self = try Wrapped.init(from: &reader)
    default: self = .none
    }
  }
}

extension String: BorshDeserializable {
  public init(from reader: inout BinaryReader) throws {
    let count: UInt32 = try .init(from: &reader)
    let bytes = reader.read(count: count)
    guard let value = String(bytes: bytes, encoding: .utf8) else {throw DeserializationError.noData}
    self = value
  }
}

extension Array: BorshDeserializable where Element: BorshDeserializable {
  public init(from reader: inout BinaryReader) throws {
    let count: UInt32 = try .init(from: &reader)
    self = try [UInt32](0..<count).map {_ in try Element.init(from: &reader) }
  }
}

extension Set: BorshDeserializable where Element: BorshDeserializable & Equatable {
  public init(from reader: inout BinaryReader) throws {
    self = try Set([Element].init(from: &reader))
  }
}

extension Dictionary: BorshDeserializable where Key: BorshDeserializable & Equatable, Value: BorshDeserializable {
  public init(from reader: inout BinaryReader) throws {
    let count: UInt32 = try .init(from: &reader)
    let keyValuePairs = try [UInt32](0..<count)
      .map {_ in (try Key.init(from: &reader), try Value.init(from: &reader)) }
    self = Dictionary(uniqueKeysWithValues: keyValuePairs)
  }
}
