import Foundation

extension NSRegularExpression {
    public func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }

    public static let publicKey = try! NSRegularExpression(pattern: #"^[1-9A-HJ-NP-Za-km-z]{32,44}$"#)
}
