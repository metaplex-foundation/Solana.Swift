import Foundation

extension Error {
    public var readableDescription: String? {
        (self as? LocalizedError)?.errorDescription ?? localizedDescription
    }
}
