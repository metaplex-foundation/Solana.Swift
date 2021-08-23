import Foundation
import TweetNacl

public struct Ed25519HDKey {
    public typealias Hex = String
    public typealias Path = String

    public enum Error: Swift.Error {
        case invalidDerivationPath
        case hmacCanNotAuthenticate
        case canNotGetMasterKeyFromSeed
    }

    private static let ed25519Curve = "ed25519 seed"
    public static let hardenedOffset = 0x80000000

    public static func getMasterKeyFromSeed(_ seed: Hex) -> Result<Keys, Error> {
        let hmacKey = ed25519Curve.bytes

        guard let entropy = hmacSha512(message: Data(hex: seed), key: Data(hmacKey)) else {
            return .failure(.hmacCanNotAuthenticate)
        }
        let IL = Data(entropy[0..<32])
        let IR = Data(entropy[32...])
        return .success(Keys(key: IL, chainCode: IR))
    }

    private static func CKDPriv(keys: Keys, index: UInt32) -> Result<Keys, Error> {
        var bytes = [UInt8]()
        bytes.append(UInt8(0))
        bytes += keys.key.bytes
        bytes += index.edBytes
        let data = Data(bytes)

        guard let entropy = hmacSha512(message: data, key: keys.chainCode) else {
            return .failure(.hmacCanNotAuthenticate)
        }
        let IL = Data(entropy[0..<32])
        let IR = Data(entropy[32...])
        return .success(Keys(key: IL, chainCode: IR))
    }

    public static func getPublicKey(privateKey: Data, withZeroBytes: Bool = true) throws -> Data {
        let keyPair = try NaclSign.KeyPair.keyPair(fromSeed: privateKey)
        let signPk = keyPair.secretKey[32...]
        let zero = Data([UInt8(0)])
        return withZeroBytes ? Data(zero + signPk): Data(signPk)
    }

    public static func derivePath(_ path: Path, seed: Hex, offSet: Int = hardenedOffset) -> Result<Keys, Error> {
        guard path.isValidDerivationPath else {
            return .failure(Error.invalidDerivationPath)
        }

        return getMasterKeyFromSeed(seed).flatMap { keys in
            let segments = path.components(separatedBy: "/")[1...]
                .map {$0.replacingDerive}
                .map {Int($0)!}
            return .success((keys:keys, segments: segments))
        }.flatMap { (keys: Keys, segments: [Int]) in
            do {
                let keys = try segments.reduce(keys, { try CKDPriv(keys: $0, index: UInt32($1+offSet)).get() })
                return .success(keys)
            } catch {
                return .failure(.canNotGetMasterKeyFromSeed)
            }
        }
    }
}
