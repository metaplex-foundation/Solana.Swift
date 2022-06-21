import Foundation

public struct TokenExtensions: Hashable, Decodable {
    public let address: String?
    public let assetContract: String?
    public let bridgeContract: String?
    public let coingeckoId: String?
    public let description: String?
    public let discord: String?
    public let facebook: String?
    public let instagram: String?
    public let medium: String?
    public let reddit: String?
    public let telegram: String?
    public let serumV3Usdc: String?
    public let twitter: String?
    public let website: String?
}

public struct Token: Hashable, Decodable {
    public init(
        chainId: Int?,
        address: String,
        symbol: String?,
        name: String?,
        logoURI: String?,
        extensions: TokenExtensions?,
        tags: [String] = [],
        isNative: Bool = false
    ) {
        self.chainId = chainId
        self.address = address
        self.symbol = symbol
        self.name = name
        self.logoURI = logoURI
        self.tags = tags
        self.extensions = extensions
        self.isNative = isNative
    }
    
    public init(address: String) {
        self.tags = []
        self.chainId = nil
        self.address = address
        self.symbol = nil
        self.name = nil
        self.logoURI = nil
        self.extensions = nil
        self.isNative = false
    }
    
    public let chainId: Int?
    public let address: String
    public let symbol: String?
    public let name: String?
    public let logoURI: String?
    public let extensions: TokenExtensions?
    public let tags: [String]?
    public private(set) var isNative = false
    
    enum CodingKeys: String, CodingKey {
        case chainId, address, symbol, name, logoURI, extensions, tags
    }
}
