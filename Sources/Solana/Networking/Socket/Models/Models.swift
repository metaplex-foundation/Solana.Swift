import Foundation


public enum SocketMethod: String {
    case accountNotification
    case accountSubscribe
    case accountUnsubscribe
    
    case signatureNotification
    case signatureSubscribe
    case signatureUnsubscribe
}

public struct SocketSubscription {
    let method: SocketMethod
    let id: UInt64
    var account: String?
}

public struct SocketResponse<T: Decodable>: Decodable {
    public let jsonrpc: String
    public let method: String?
    public let params: Params<T>?
    public let result: T?
}

public struct Params<T: Decodable>: Decodable {
    public let result: Rpc<T>?
    public let subscription: UInt64?
}

public struct AccountNotification<T: Decodable>: Decodable {
    public let data: T
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

public typealias SOLAccountNotification = SocketResponse<AccountNotification<[String]>>
public typealias TokenAccountNotification = SocketResponse<AccountNotification<TokenAccountNotificationData>>
