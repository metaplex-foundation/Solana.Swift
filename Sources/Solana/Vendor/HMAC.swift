import Foundation
import CommonCrypto

func hmac(hmacAlgorithm: HMACAlgorithm, message: Data, key: Data) -> Data? {
    let hashAlgorithm = hmacAlgorithm.HMACAlgorithm
    let length = hmacAlgorithm.digestLength
    var macData = Data(count: Int(length))

    macData.withUnsafeMutableBytes { (macBytes) in
        message.withUnsafeBytes { (messageBytes) in
            key.withUnsafeBytes { (keyBytes) in
                CCHmac(CCHmacAlgorithm(hashAlgorithm),
                       keyBytes,
                       key.count,
                       messageBytes,
                       message.count,
                       macBytes)
            }
        }
    }
    return macData
}

func hmacSha512(message: Data, key: Data) -> Data? {
    let messageData = message
    let keyData = key
    return hmac(hmacAlgorithm: .SHA512, message: messageData, key: keyData)
}

enum HMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512

    var HMACAlgorithm: Int {
        switch self {
        case .MD5:      return kCCHmacAlgMD5
        case .SHA1:     return kCCHmacAlgSHA1
        case .SHA224:   return kCCHmacAlgSHA224
        case .SHA256:   return kCCHmacAlgSHA256
        case .SHA384:   return kCCHmacAlgSHA384
        case .SHA512:   return kCCHmacAlgSHA512
        }
    }

    var digestLength: Int32 {
        switch self {
        case .MD5:      return CC_MD5_DIGEST_LENGTH
        case .SHA1:     return CC_SHA1_DIGEST_LENGTH
        case .SHA224:   return CC_SHA224_DIGEST_LENGTH
        case .SHA256:   return CC_SHA256_DIGEST_LENGTH
        case .SHA384:   return CC_SHA384_DIGEST_LENGTH
        case .SHA512:   return CC_SHA512_DIGEST_LENGTH
        }
    }
}
