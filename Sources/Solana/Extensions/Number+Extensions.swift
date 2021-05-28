import Foundation

extension UInt32 {
    var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }
}

extension UInt64 {
    var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }

    public func convertToBalance(decimals: Int?) -> Double {
        guard let decimals = decimals else {return 0}
        return convertToBalance(decimals: UInt8(decimals))
    }

    public func convertToBalance(decimals: UInt8?) -> Double {
        guard let decimals = decimals else {return 0}
        return Double(self) * pow(10, -Double(decimals))
    }
}

extension Double {
    public func toLamport(decimals: Int) -> UInt64 {
        UInt64((self * pow(10, Double(decimals))).rounded())
    }
    public func toLamport(decimals: UInt8) -> UInt64 {
        toLamport(decimals: Int(decimals))
    }
}
