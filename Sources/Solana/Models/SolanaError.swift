import Foundation

public extension Solana {
    enum SolanaError: Error {
        case unauthorized
        case notFoundProgramAddress
        case invalidRequest(reason: String? = nil)
        case invalidResponse(ResponseError)
        case socket(Error)
        case couldNotRetriveAccountInfo
        case other(String)
        case nullValue
        case couldNotRetriveBalance
        case blockHashNotFound
    }
}
