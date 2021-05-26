//
//  Ed25519HDKey.swift
//  Ed25519HDKeySwift
//
//  Created by Chung Tran on 07/05/2021.
//

import Foundation
import TweetNacl
import CryptoSwift

public struct Ed25519HDKey {
    public typealias Hex = String
    public typealias Path = String

    public enum Error: Swift.Error {
        case invalidDerivationPath
    }

    private static let ed25519Curve = "ed25519 seed"
    public static let hardenedOffset = 0x80000000

    public static func getMasterKeyFromSeed(_ seed: Hex) throws -> Keys {
        let hmacKey = ed25519Curve.bytes
        let hmac = HMAC(key: hmacKey, variant: .sha512)
        let entropy = try hmac.authenticate(Data(hex: seed).bytes)
        let IL = Data(entropy[0..<32])
        let IR = Data(entropy[32...])
        return Keys(key: IL, chainCode: IR)
    }

    private static func CKDPriv(keys: Keys, index: UInt32) throws -> Keys {
        var bytes = [UInt8]()
        bytes.append(UInt8(0))
        bytes += keys.key.bytes
        bytes += index.edBytes
        let data = Data(bytes)

        let hmac = HMAC(key: keys.chainCode.bytes, variant: .sha512)

        let entropy = try hmac.authenticate(data.bytes)
        let IL = Data(entropy[0..<32])
        let IR = Data(entropy[32...])
        return Keys(key: IL, chainCode: IR)
    }

    public static func getPublicKey(privateKey: Data, withZeroBytes: Bool = true) throws -> Data {
        let keyPair = try NaclSign.KeyPair.keyPair(fromSeed: privateKey)
        let signPk = keyPair.secretKey[32...]
        let zero = Data([UInt8(0)])
        return withZeroBytes ? Data(zero + signPk): Data(signPk)
    }

    public static func derivePath(_ path: Path, seed: Hex, offSet: Int = hardenedOffset) throws -> Keys {
        guard path.isValidDerivationPath else {
            throw Error.invalidDerivationPath
        }

        let keys = try getMasterKeyFromSeed(seed)
        let segments = path.components(separatedBy: "/")[1...]
            .map {$0.replacingDerive}
            .map {Int($0)!}

        return try segments.reduce(keys, {try CKDPriv(keys: $0, index: UInt32($1+offSet))})
    }
}
