import Foundation

extension Double {
    public func toLamport(decimals: Int) -> UInt64 {
        UInt64((self * pow(10, Double(decimals))).rounded())
    }
    public func toLamport(decimals: UInt8) -> UInt64 {
        toLamport(decimals: Int(decimals))
    }
}
