import Foundation
import CommonCrypto

func pbkdf2(hash: CCPBKDFAlgorithm, password: String, salt: Data, keyByteCount: Int, rounds: Int) -> Data? {
    let passwordData = password.data(using: String.Encoding.utf8)!
    var derivedKeyData = Data(repeating: 0, count: keyByteCount)
    let derivedKeyDataCount = derivedKeyData.count
    let derivationStatus = derivedKeyData.withUnsafeMutableBytes { (rawMutableBufferPointer: UnsafeMutableRawBufferPointer) -> Int32 in
        let derivedKeyBytes = rawMutableBufferPointer.bindMemory(to: UInt8.self)
        return CCKeyDerivationPBKDF(
            CCPBKDFAlgorithm(kCCPBKDF2),
            password,
            passwordData.count,
            salt.bytes,
            salt.count,
            hash,
            UInt32(rounds),
            derivedKeyBytes.baseAddress,
            derivedKeyDataCount)
    }

    if derivationStatus != kCCSuccess {
        print("Error: \(derivationStatus)")
        return nil
    }

    return derivedKeyData
}
