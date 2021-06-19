import Foundation

struct SolanaRequest: Encodable {
    public init(method: String, params: [Encodable]) {
        self.method = method
        self.params = params
    }

    public let id = UUID().uuidString
    public let method: String
    public let jsonrpc: String = "2.0"
    public let params: [Encodable]

    enum CodingKeys: String, CodingKey {
        case id
        case method
        case jsonrpc
        case params
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(method, forKey: .method)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        let wrappedDict = params.map(EncodableWrapper.init(wrapped:))
        try container.encode(wrappedDict, forKey: .params)
    }
}

public struct EncodableWrapper: Encodable {
    let wrapped: Encodable

    public func encode(to encoder: Encoder) throws {
        try self.wrapped.encode(to: encoder)
    }
}
