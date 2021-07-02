import Foundation
import Accelerate.vecLib

public typealias Int1X = FixedWidthInteger & BinaryInteger & SignedInteger & Codable

public struct Int2X<Word:UInt1X>: Hashable, Codable {
    public typealias IntegerLiteralType = UInt64
    public typealias Magnitude = UInt2X<Word>
    public typealias Words = [Word.Words.Element]
    public typealias Stride = Int
    public var rawValue:Magnitude = 0
    public init(rawValue:Magnitude){ self.rawValue = rawValue }
    public init(_ source:Int2X) { self.rawValue = source.rawValue }
    public init() {}
}
// Swift bug?
// auto-generated == fatalError()'s
// UInt2X(hi:nonzero, lo:0) == 0
extension Int2X {
    public static func == (_ lhs: Int2X, _ rhs: Int2X)->Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
extension Int2X : ExpressibleByIntegerLiteral {
    public static var isSigned: Bool { return true }
    public static var bitWidth: Int { return Magnitude.bitWidth }
    public static var max:Int2X { return Int2X(rawValue:(Magnitude.max >> 1))    }
    public static var min:Int2X { return Int2X(rawValue:(Magnitude.max >> 1) &+ 1) }
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard source.bitWidth <= Int2X.bitWidth || source.magnitude <= T(Int2X.max.rawValue) else {
            return nil
        }
        if !T.isSigned && source & (1 << (source.bitWidth - 1)) != 0 {
            return nil
        }
        self.init(source)
    }
    public init<T>(_ source: T) where T : BinaryInteger {
        if !T.isSigned && Word.bitWidth * 2 <= source.bitWidth && source & (1 << (source.bitWidth - 1)) != 0 {
            fatalError("Not enough bits to represent a signed value")
        }
        self.rawValue = Magnitude(source.magnitude)
        if T.isSigned && source & (1 << (source.bitWidth - 1)) != 0 {
            self.rawValue = -self.rawValue
        }
    }
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        guard let rv = Magnitude(exactly: source.sign == .minus ? -source : +source) else { return nil }
        self = Int2X(rawValue:rv)
        guard !self.isNegative else { return nil }
        if source.sign == .minus { self = -self }
    }
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        guard let result = Int2X(exactly: source) else {
            fatalError("Not enough bits to represent a signed value")
        }
        self = result
    }
    // alway succeeds
    public init<T:BinaryInteger>(truncatingIfNeeded source: T) {
        self.rawValue = Magnitude(truncatingIfNeeded:source.magnitude)
        if T.isSigned && source < 0 {
            self.rawValue = -self.rawValue
        }
    }
    // alway succeeds
    public init<T:BinaryInteger>(clamping source: T) {
        self = Int2X(exactly: source) ?? Int2X.max
    }
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}
extension Int2X : Comparable {
    internal var isNegative:Bool {
        return Int2X.max.rawValue < self.rawValue
    }
    public var magnitude:Magnitude {
        return isNegative ? rawValue == Int2X.min.rawValue ? rawValue : -rawValue : +rawValue
    }
    public static func < (lhs: Int2X, rhs: Int2X) -> Bool {
        return Int2X.max.rawValue < lhs.rawValue &- rhs.rawValue
    }
}
extension Int2X : Numeric {
    // unary operators
    public static prefix func ~(_ value:Int2X)->Int2X {
        return Int2X(rawValue:~(value.rawValue))
    }
    public static prefix func +(_ value:Int2X)->Int2X {
        return value
    }
    public static prefix func -(_ value:Int2X)->Int2X {
        return Int2X(rawValue:-(value.rawValue))
    }
    // additions
    public func addingReportingOverflow(_ other: Int2X) -> (partialValue: Int2X, overflow: Bool) {
        let (pv, of) = self.rawValue.addingReportingOverflow(other.rawValue)
        // For any given int the only possible case that overflows is I.min - I.min
        // in which case overflow is true and partialValue is 0
        return (Int2X(rawValue:pv), of && pv == 0)
        
    }
    public static func &+(_ lhs:Int2X, _ rhs:Int2X)->Int2X {
        return lhs.addingReportingOverflow(rhs).partialValue
    }
    public static func +(_ lhs:Int2X, _ rhs:Int2X)->Int2X {
        let (pv, of) = lhs.addingReportingOverflow(rhs)
        precondition(!of, "\(lhs) + \(rhs): Addition overflow!")
        return pv
    }
    public static func += (lhs: inout Int2X, rhs: Int2X) {
        lhs = lhs + rhs
    }
    // subtraction
    public func subtractingReportingOverflow(_ other: Int2X) -> (partialValue: Int2X, overflow: Bool) {
        let (pv, of) = self.rawValue.subtractingReportingOverflow(other.rawValue)
        return (Int2X(rawValue:pv), of && pv == 0)
    }
    public static func &-(_ lhs:Int2X, _ rhs:Int2X)->Int2X {
        return lhs.subtractingReportingOverflow(rhs).partialValue
    }
    public static func -(_ lhs:Int2X, _ rhs:Int2X)->Int2X {
        let (pv, of) = lhs.subtractingReportingOverflow(rhs)
        precondition(!of, "\(lhs) - \(rhs): Subtruction overflow!")
        return pv
    }
    public static func -= (lhs: inout Int2X, rhs: Int2X) {
        lhs = lhs - rhs
    }
    // multiplication
    public func multipliedFullWidth(by other: Int2X) -> (high: Int2X, low: Magnitude) {
        let (h, l) = self.rawValue.multipliedFullWidth(by:other.rawValue)
        return (Int2X(h), l)
        
    }
    public func multipliedReportingOverflow(by other: Int2X) -> (partialValue: Int2X, overflow: Bool) {
        let hv = self.magnitude.multipliedFullWidth(by: other.magnitude)
        return (self.isNegative != other.isNegative ? -Int2X(rawValue:hv.low) : +Int2X(rawValue:hv.low), 0 < hv.high)
    }
    public static func &*(lhs: Int2X, rhs: Int2X) -> Int2X {
        return lhs.multipliedReportingOverflow(by: rhs).partialValue
    }
    public static func *(lhs: Int2X, rhs: Int2X) -> Int2X {
        let result = lhs.multipliedReportingOverflow(by: rhs)
        precondition(!result.overflow, "Multiplication overflow!")
        return result.partialValue
    }
    public static func *= (lhs: inout Int2X, rhs: Int2X) {
        lhs = lhs * rhs
    }
}
// bitshifts
extension Int2X {
    public static func &>>(_ lhs:Int2X, _ rhs:Int2X)->Int2X {
        if rhs.isNegative { return lhs &<< -rhs }
        if Int2X.bitWidth <= rhs { return 0 }
        let rv = lhs.magnitude &>> rhs.magnitude
        return lhs.isNegative ? -Int2X(rawValue:rv) : +Int2X(rawValue:rv)
    }
    public static func &<<(_ lhs:Int2X, _ rhs:Int2X)->Int2X {
        if rhs.isNegative { return lhs &>> -rhs }
        if Int2X.bitWidth <= rhs { return 0 }
        let rv = lhs.magnitude &<< rhs.magnitude
        return lhs.isNegative ? -Int2X(rawValue:rv) : +Int2X(rawValue:rv)
    }
    public static func &>>=(_ lhs:inout Int2X, _ rhs:Int2X) {
        return lhs = lhs &>> rhs
    }
    public static func &<<=(_ lhs:inout Int2X, _ rhs:Int2X) {
        return lhs = lhs &<< rhs
    }
}
// division
extension Int2X {
    public func quotientAndRemainder(dividingBy other: Int2X) -> (quotient: Int2X, remainder: Int2X) {
        let qv = self.magnitude.quotientAndRemainder(dividingBy:other.magnitude)
        let q = self.isNegative != other.isNegative ? -qv.quotient : +qv.quotient
        let r = self.isNegative ? -qv.remainder : +qv.remainder
        return (Int2X(rawValue:q), Int2X(rawValue:r))
    }
    public static func / (_ lhs:Int2X, rhs:Int2X)->Int2X {
        return lhs.quotientAndRemainder(dividingBy: rhs).quotient
    }
    public static func /= (_ lhs:inout Int2X, rhs:Int2X) {
        lhs = lhs / rhs
    }
    public static func % (_ lhs:Int2X, rhs:Int2X)->Int2X {
        return lhs.quotientAndRemainder(dividingBy: rhs).remainder
    }
    public static func %= (_ lhs:inout Int2X, rhs:Int2X) {
        lhs = lhs % rhs
    }
    public func dividedReportingOverflow(by other :Int2X) -> (partialValue: Int2X, overflow:Bool) {
        return (self / other, false)
    }
    public func remainderReportingOverflow(dividingBy other :Int2X) -> (partialValue: Int2X, overflow:Bool) {
        return (self % other, false)
    }
    public func dividingFullWidth(_ dividend: (high: Int2X, low: Magnitude)) -> (quotient: Int2X, remainder: Int2X) {
        let qv = self.magnitude.dividingFullWidth((high: dividend.high.magnitude, low: dividend.low))
        let q = self.isNegative != dividend.high.isNegative ? -qv.quotient : +qv.quotient
        let r = self.isNegative ? -qv.remainder : +qv.remainder
        return (Int2X(rawValue:q), Int2X(rawValue:r))
    }
}
// UInt2X -> String
extension Int2X : CustomStringConvertible, CustomDebugStringConvertible {
    public func toString(radix:Int=10, uppercase:Bool=false) -> String {
        return (self.isNegative ? "-" : "") + self.magnitude.toString(radix:radix, uppercase:uppercase)
    }
    public var description:String {
        return toString()
    }
    public var debugDescription:String {
        return (self.isNegative ? "-" : "+") + "0x" + self.magnitude.toString(radix:16)
    }
}
extension StringProtocol {
    public init?<Word>(_ source:Int2X<Word>, radix:Int=10, uppercase:Bool=false) {
        self.init(source.toString(radix:radix, uppercase:uppercase))
    }
}
// String <- UInt2X
extension Int2X : ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init()
        if let result = Int2X.fromString(value) {
            self = result
        }
    }
    internal static func fromString(_ value: String) -> Int2X? {
        var source = value
        var sign   = "+"
        if source.first == "-" || source.first == "+" {
            sign = String(source.first!)
            source.removeFirst()
        }
        guard let magnitude = Magnitude.fromString(source) else { return nil }
        return sign == "-" ? -Int2X(rawValue: magnitude) : +Int2X(rawValue: magnitude)
    }
}
// Int -> Int2X
extension Int {
    public init<Word>(_ source:Int2X<Word>) {
        let a = Int(bitPattern: UInt(source.magnitude))
        self.init(source.isNegative ? -a : +a)
    }
}
// Strideable
extension Int2X: Strideable {
    public func distance(to other: Int2X) -> Int {
        return Int(other) - Int(self)
    }
    public func advanced(by n: Int) -> Int2X {
        return self + Int2X(n)
    }
}
// BinaryInteger
extension Int2X: BinaryInteger {
    public var bitWidth: Int {
        return rawValue.bitWidth
    }
    public var words: Words {
        return rawValue.words
    }
    public var trailingZeroBitCount: Int {
        return rawValue.trailingZeroBitCount
    }
    public static func &= (lhs: inout Int2X, rhs: Int2X) {
        lhs.rawValue &= rhs.rawValue
    }
    public static func |= (lhs: inout Int2X, rhs: Int2X) {
        lhs.rawValue |= rhs.rawValue
    }
    public static func ^= (lhs: inout Int2X, rhs: Int2X) {
        lhs.rawValue ^= rhs.rawValue
    }
    public static func <<= <RHS>(lhs: inout Int2X, rhs: RHS) where RHS : BinaryInteger {
        lhs.rawValue <<= rhs
    }
    public static func >>= <RHS>(lhs: inout Int2X, rhs: RHS) where RHS : BinaryInteger {
        lhs.rawValue >>= rhs
    }
}
// FixedWidthInteger
extension Int2X: FixedWidthInteger {
    public init(_truncatingBits bits: UInt) {
        fatalError()
    }
    public var nonzeroBitCount: Int {
        return self.rawValue.nonzeroBitCount
    }
    public var leadingZeroBitCount: Int {
        return self.rawValue.leadingZeroBitCount
    }
    public var byteSwapped: Int2X {
        return Int2X(rawValue:rawValue.byteSwapped)
    }
}
// SignedInteger
extension Int2X: SignedInteger {}

public typealias Int128    = Int2X<UInt64>
public typealias Int256    = Int2X<UInt128>
public typealias Int512    = Int2X<UInt256>
public typealias Int1024   = Int2X<UInt512>

