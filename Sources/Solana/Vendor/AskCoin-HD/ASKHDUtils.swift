//
//  ASKHDUtils.swift
//  AskCoin-HD
//
//  Created by 仇弘扬 on 2017/8/16.
//  Copyright © 2017年 askcoin. All rights reserved.
//

import Foundation

protocol HexToData {
	func ask_hexToData() -> Data
}

extension UInt32: HexToData {
	func ask_hexToData() -> Data {
		var v = self.byteSwapped
		let data = Data(bytes: &v, count: MemoryLayout<UInt32>.size)
		return data
	}
}

extension UInt8: HexToData {
	func ask_hexToData() -> Data {
		var v = self
		let data = Data(bytes: &v, count: MemoryLayout<UInt8>.size)
		return data
	}
}

extension String {

	/// Create `Data` from hexadecimal string representation
	///
	/// This takes a hexadecimal representation and creates a `Data` object. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
	///
	/// - returns: Data represented by this hexadecimal string.

	func ask_hexadecimal() -> Data? {
		var data = Data(capacity: self.count / 2)

		let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
		regex.enumerateMatches(in: self, range: NSRange(location: 0, length: utf16.count)) { match, _, _ in
			let byteString = (self as NSString).substring(with: match!.range)
			var num = UInt8(byteString, radix: 16)!
			data.append(&num, count: 1)
		}

		guard data.count > 0 else { return nil }

		return data
	}

}

extension Data {

	/// Create hexadecimal string representation of `Data` object.
	///
	/// - returns: `String` representation of this `Data` object.

	func ask_hexadecimal() -> String {
		return map { String(format: "%02x", $0) }
			.joined(separator: "")
	}
}

extension Data {
	func ask_BTCHash256() -> Data {
		return sha256(data: self)
	}
	func ask_BTCHash160() -> Data {
        return RIPEMD.digest(sha256(data: self))
	}
	func ask_BTCHash160String() -> String {
		return ask_BTCHash160().toHexString()
	}
	func ck_reversedData() -> Data {
		return Data(reversed())
	}
	func ask_base58Check() -> String {
		return Base58.encode([UInt8](self))
	}
	static func dataFromHexString(hexString: String) -> Data {
		let data = Data()

		return data
	}
}

// Copy from CryptoSwift/UInt32+Extension.swift
extension UInt32 {

	init<T: Collection>(bytes: T) where T.Iterator.Element == UInt8, T.Index == Int {
		self = UInt32(bytes: bytes, fromIndex: bytes.startIndex)
	}

	init<T: Collection>(bytes: T, fromIndex index: T.Index) where T.Iterator.Element == UInt8, T.Index == Int {
		let val0 = UInt32(bytes[index.advanced(by: 0)]) << 24
		let val1 = UInt32(bytes[index.advanced(by: 1)]) << 16
		let val2 = UInt32(bytes[index.advanced(by: 2)]) << 8
		let val3 = UInt32(bytes[index.advanced(by: 3)])

		self = val0 | val1 | val2 | val3
	}
}
