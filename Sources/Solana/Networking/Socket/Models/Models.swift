import Foundation

public enum SocketMethod: String {
    case accountNotification
    case accountSubscribe
    case accountUnsubscribe

    case signatureNotification
    case signatureSubscribe
    case signatureUnsubscribe

    case logsSubscribe
    case logsNotification
    case logsUnsubscribe

    case programSubscribe
    case programNotification
    case programUnsubscribe

    case slotSubscribe
    case slotNotification
    case slotUnsubscribe
}

struct SocketSubscription: Decodable {
    let jsonrpc: String
    let id: String
    let result: UInt64
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

public struct LogsNotification: Decodable {
    let signature: String
    let logs: [String]
    let err: ResponseError?
}
