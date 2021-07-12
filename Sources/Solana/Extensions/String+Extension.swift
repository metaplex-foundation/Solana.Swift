import Foundation

extension String {
    @inlinable
    public var bytes: Array<UInt8> {
        data(using: String.Encoding.utf8, allowLossyConversion: true)?.bytes ?? Array(utf8)
    }
}
