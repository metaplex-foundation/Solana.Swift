//
//  Base58.swift
//  NeoSwift
//
//  Created by Luís Silva on 11/09/17.
//  Copyright © 2017 drei. All rights reserved.
//

import Foundation

public struct Base58 {
    static let base58Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    // Encode
    public static func encode(_ bytes: [UInt8]) -> String {
        var bytes = bytes
        var zerosCount = 0
        var length = 0

        for b in bytes {
            if b != 0 { break }
            zerosCount += 1
        }

        bytes.removeFirst(zerosCount)

        let size = bytes.count * 138 / 100 + 1

        var base58: [UInt8] = Array(repeating: 0, count: size)
        for b in bytes {
            var carry = Int(b)
            var i = 0

            for j in 0...base58.count-1 where carry != 0 || i < length {
                carry += 256 * Int(base58[base58.count - j - 1])
                base58[base58.count - j - 1] = UInt8(carry % 58)
                carry /= 58
                i += 1
            }

            assert(carry == 0)

            length = i
        }

        // skip leading zeros
        var zerosToRemove = 0
        var str = ""
        for b in base58 {
            if b != 0 { break }
            zerosToRemove += 1
        }
        base58.removeFirst(zerosToRemove)

        while 0 < zerosCount {
            str = "\(str)1"
            zerosCount -= 1
        }

        for b in base58 {
            str = "\(str)\(base58Alphabet[String.Index(encodedOffset: Int(b))])"
        }

        return str
    }

    // Decode
    public static func decode(_ base58: String) -> [UInt8] {
        // remove leading and trailing whitespaces
        let string = base58.trimmingCharacters(in: CharacterSet.whitespaces)

        guard !string.isEmpty else { return [] }

        var zerosCount = 0
        var length = 0
        for c in string {
            if c != "1" { break }
            zerosCount += 1
        }

        let size = string.lengthOfBytes(using: String.Encoding.utf8)
        var base58: [UInt8] = Array(repeating: 0, count: size)
        for c in string where c != " " {
            // search for base58 character
            guard let base58Index = base58Alphabet.firstIndex(of: c) else { return [] }

            var carry = base58Index.encodedOffset
            var i = 0
            for j in 0...base58.count where carry != 0 || i < length {
                carry += 58 * Int(base58[base58.count - j - 1])
                base58[base58.count - j - 1] = UInt8(carry % 256)
                carry /= 256
                i += 1
            }

            assert(carry == 0)
            length = i
        }

        // skip leading zeros
        var zerosToRemove = 0

        for b in base58 {
            if b != 0 { break }
            zerosToRemove += 1
        }
        base58.removeFirst(zerosToRemove)

        var result: [UInt8] = Array(repeating: 0, count: zerosCount)
        for b in base58 {
            result.append(b)
        }
        return result
    }
}
