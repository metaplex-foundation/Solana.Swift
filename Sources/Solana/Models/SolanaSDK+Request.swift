import Foundation

public struct Transfer {
    public static func compile() -> Data {
        var result = Data(capacity: 17) // FIXME: - capacity
        result.append(0x2) // program index
        let keyIndeces = [UInt8]([0, 1])
        result.append(Data.encodeLength(keyIndeces.count)) // key size
        result.append(contentsOf: keyIndeces) // keyIndeces
        result.append(UInt8(12))   // FIXME transfer data size
        
        result += UInt32(2).bytes // Program Index
        
        let lamports = 3000
        result += UInt64(lamports).bytes
        
        return result
    }
}

public typealias Commitment = String

public struct RequestConfiguration: Encodable {
    public let commitment: Commitment?
    public let encoding: String?
    public let dataSlice: DataSlice?
    public let filters: [[String: EncodableWrapper]]?
    public let limit: Int?
    public let before: String?
    public let until: String?
    
    public init?(commitment: Commitment? = nil, encoding: String? = nil, dataSlice: DataSlice? = nil, filters: [[String: EncodableWrapper]]? = nil, limit: Int? = nil, before: String? = nil, until: String? = nil) {
        if commitment == nil && encoding == nil && dataSlice == nil && filters == nil && limit == nil && before == nil && until == nil {
            return nil
        }
        self.commitment = commitment
        self.encoding = encoding
        self.dataSlice = dataSlice
        self.filters = filters
        self.limit = limit
        self.before = before
        self.until = until
    }
}

public struct DataSlice: Encodable {
    public let offset: Int
    public let length: Int
}
