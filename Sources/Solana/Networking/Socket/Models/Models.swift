import Foundation

public enum SocketMethod: String {
    case accountNotification
    case accountSubscribe
    case accountUnsubscribe
    
    case signatureNotification
    case signatureSubscribe
    case signatureUnsubscribe
}

struct SocketSubscription: Decodable {
    let jsonrpc: String
    let id: String
    let result: UInt64
}

public struct AccountNotification<T: Decodable>: Decodable {
    public let data: T?
    public let lamports: Lamports
    public let owner: String
    public let executable: Bool
    public let rentEpoch: UInt64
}

public struct TokenAccountNotificationData: Decodable {
    public let program: String
    public let parsed: TokenAccountNotificationDataParsed
}

public struct TokenAccountNotificationDataParsed: Decodable {
    public let type: String
    public let info: TokenAccountNotificationDataInfo
}

public struct TokenAccountNotificationDataInfo: Decodable {
    public let tokenAmount: TokenAmount
}

public struct SignatureNotification: Decodable {
    let err: ResponseError?
}
