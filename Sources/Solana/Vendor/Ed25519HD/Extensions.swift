import Foundation

// MARK: - Derivation path
extension String {
    var isValidDerivationPath: Bool {
        range(of: "^m(\\/[0-9]+'?)+$", options: .regularExpression, range: nil, locale: nil) != nil
    }

    var replacingDerive: String {
        replacingOccurrences(of: "'", with: "")
    }
}

// MARK: - Bytes
extension UInt32 {
    var edBytes: [UInt8] {
        var bigEndian = self.bigEndian
        let count = MemoryLayout<UInt32>.size
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        return Array(bytePtr)
    }
}
