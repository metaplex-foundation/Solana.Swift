import Foundation

public typealias BorshCodable = BorshSerializable & BorshDeserializable

public enum BorshDecodingError: Error {
  case unknownData
}
