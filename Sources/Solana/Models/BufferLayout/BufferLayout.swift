import Foundation

public enum BufferLayoutError: Error {
    case NotImplemented
}
public protocol BufferLayout: Codable, BorshCodable {
    static var BUFFER_LENGTH: UInt64 { get }
}

public struct Buffer<T: BufferLayout>: Codable {
    public let value: T?

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // decode parsedJSON
        if let parsedData = try? container.decode(T.self) {
            value = parsedData
            return
        }

        // Unable to get parsed data, fallback to decoding base64
        let stringData = (try? container.decode([String].self).first) ?? (try? container.decode(String.self))
        guard let string = stringData, let data = Data(base64Encoded: string)?.bytes,
              data.count >= T.BUFFER_LENGTH
        else {
            value = nil
            return
        }

        var reader = BinaryReader(bytes: data)
        value = try T.init(from: &reader)
    }
}
