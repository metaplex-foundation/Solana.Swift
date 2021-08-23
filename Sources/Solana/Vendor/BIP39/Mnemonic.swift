//
//  Mnemonic.swift
//
//  See BIP39 specification for more info:
//  https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
//
//  Created by Liu Pengpeng on 2019/10/10.
//

import Foundation
import CryptoKit
import CommonCrypto

public class Mnemonic {
    public enum Error: Swift.Error {
        case invalidMnemonic
        case invalidEntropy
        case doesntMatch
    }

    public let phrase: [String]
    let passphrase: String

    public init(strength: Int = 256, wordlist: [String] = Wordlists.english) {
        precondition(strength % 32 == 0, "Invalid entropy")

        // 1.Random Bytes
        var bytes = [UInt8](repeating: 0, count: strength / 8)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        // 2.Entropy -> Mnemonic
        let entropyBits = String(bytes.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let checksumBits = Mnemonic.deriveChecksumBits(bytes)
        let bits = entropyBits + checksumBits

        var phrase = [String]()
        for i in 0..<(bits.count / 11) {
            let wi = Int(bits[bits.index(bits.startIndex, offsetBy: i * 11)..<bits.index(bits.startIndex, offsetBy: (i + 1) * 11)], radix: 2)!
            phrase.append(String(wordlist[wi]))
        }

        self.phrase = phrase
        self.passphrase = ""
    }

    public init?(phrase: [String], passphrase: String = "") {
        if !Mnemonic.isValid(phrase: phrase) {
            return nil
        }
        self.phrase = phrase
        self.passphrase = passphrase
    }

    public init?(entropy: [UInt8], wordlist: [String] = Wordlists.english) {
        guard let phrase = try? Mnemonic.toMnemonic(entropy, wordlist: wordlist).get() else {
            return nil
        }
        self.phrase = phrase
        self.passphrase = ""
    }

    // Entropy -> Mnemonic
    public static func toMnemonic(_ bytes: [UInt8], wordlist: [String] = Wordlists.english) -> Result<[String], Error> {
        let entropyBits = String(bytes.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let checksumBits = Mnemonic.deriveChecksumBits(bytes)
        let bits = entropyBits + checksumBits

        var phrase = [String]()
        for i in 0..<(bits.count / 11) {
            let wi = Int(bits[bits.index(bits.startIndex, offsetBy: i * 11)..<bits.index(bits.startIndex, offsetBy: (i + 1) * 11)], radix: 2)!
            phrase.append(String(wordlist[wi]))
        }
        return .success(phrase)
    }

    // Mnemonic -> Entropy
    public static func toEntropy(_ phrase: [String], wordlist: [String] = Wordlists.english) -> Result<[UInt8], Error> {
        let bits = phrase.map { (word) -> String in
            let index = wordlist.firstIndex(of: word)!
            var str = String(index, radix: 2)
            while str.count < 11 {
                str = "0" + str
            }
            return str
        }.joined(separator: "")

        let dividerIndex = Int(Double(bits.count / 33).rounded(.down) * 32)
        let entropyBits = String(bits.prefix(dividerIndex))
        let checksumBits = String(bits.suffix(bits.count - dividerIndex))

        guard let regex = try? NSRegularExpression(pattern: "[01]{1,8}", options: .caseInsensitive) else {
            return .failure(Error.doesntMatch)
        }
        let entropyBytes = regex.matches(in: entropyBits, options: [], range: NSRange(location: 0, length: entropyBits.count)).map {
            UInt8(strtoul(String(entropyBits[Range($0.range, in: entropyBits)!]), nil, 2))
        }
        if checksumBits != Mnemonic.deriveChecksumBits(entropyBytes) {
            return .failure(Error.invalidMnemonic)
        }
        return .success(entropyBytes)
    }

    public static func isValid(phrase: [String], wordlist: [String] = Wordlists.english) -> Bool {
        var bits = ""
        for word in phrase {
            guard let i = wordlist.firstIndex(of: word) else { return false }
            bits += ("00000000000" + String(i, radix: 2)).suffix(11)
        }

        let dividerIndex = bits.count / 33 * 32
        let entropyBits = String(bits.prefix(dividerIndex))
        let checksumBits = String(bits.suffix(bits.count - dividerIndex))

        guard let regex = try? NSRegularExpression(pattern: "[01]{1,8}", options: .caseInsensitive) else {
            return false
        }
        let entropyBytes = regex.matches(in: entropyBits, options: [], range: NSRange(location: 0, length: entropyBits.count)).map {
            UInt8(strtoul(String(entropyBits[Range($0.range, in: entropyBits)!]), nil, 2))
        }
        return checksumBits == deriveChecksumBits(entropyBytes)
    }

    public static func deriveChecksumBits(_ bytes: [UInt8]) -> String {
        let ENT = bytes.count * 8
        let CS = ENT / 32

        let hash = sha256(data: Data(bytes)).bytes
        let hashbits = String(hash.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        return String(hashbits.prefix(CS))
    }

    public var seed: [UInt8] {
        let mnemonic = (self.phrase.joined(separator: " ") as NSString).decomposedStringWithCompatibilityMapping
        let salt = (("mnemonic" + passphrase) as NSString).decomposedStringWithCompatibilityMapping
        let data = pbkdf2(hash: CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512), password: mnemonic, salt: Data(salt.bytes), keyByteCount: 64, rounds: 2048)!
        return data.bytes
    }
}

extension Mnemonic: Equatable {
    public static func == (lhs: Mnemonic, rhs: Mnemonic) -> Bool {
        return lhs.phrase == rhs.phrase && lhs.passphrase == rhs.passphrase
    }
}
