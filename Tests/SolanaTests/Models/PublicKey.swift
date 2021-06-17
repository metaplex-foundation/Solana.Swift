import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class PublicKeyTests: XCTestCase {
    
    func testKey() {
        let key = try! Solana.PublicKey(string: "11111111111111111111111111111111")
        XCTAssertNotNil(key)
    }
    
    func testKeyInvalidKey() {
        XCTAssertThrowsError(try Solana.PublicKey(string: "XX"))
        XCTAssertThrowsError(try Solana.PublicKey(bytes: nil))
        XCTAssertThrowsError(try Solana.PublicKey(data: Data(bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])))
    }
    
    func testKeyBytes() {
        let key = try! Solana.PublicKey(string: "11111111111111111111111111111111")
        XCTAssertEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], key.bytes)
        let keyB = try! Solana.PublicKey(string: "11111111111111111111111111111112")
        XCTAssertNotEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], keyB.bytes)
        
        let keyC = try! Solana.PublicKey(bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        XCTAssertEqual(key, keyC)

    }
    
    func testKeyData() {
        let key = try! Solana.PublicKey(bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        XCTAssertEqual(Data([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), key.data)
        
        let keyB = try! Solana.PublicKey(data: Data([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        XCTAssertEqual(keyB, key)
    }
    
    func testKeyEncode() {
        let key = try! Solana.PublicKey(string: "11111111111111111111111111111111")
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(key)
        XCTAssertEqual(Data([34, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 49, 34]), jsonData)
    }
    
    func testKeyDecode() {
        let keyString = "11111111111111111111111111111111"
        let targetKey = try! Solana.PublicKey(string: keyString)
        let decoder = JSONDecoder()
        let jsonData = "\"\(keyString)\"".data(using: .utf8)!
        let key = try! decoder.decode(Solana.PublicKey.self, from: jsonData)
        XCTAssertEqual(key, targetKey)
    }
    
    func testKeyShort() {
        let keyString = "11111111111111111111111111111111"
        let key = try! Solana.PublicKey(string: keyString)
        
        XCTAssertEqual("1111...1111", key.short())
    }
    
    func testKeyBase58EncodedString() {
        let keyString = "11111111111111111111111111111111"
        let key = try! Solana.PublicKey(string: keyString)
        
        XCTAssertEqual("11111111111111111111111111111111", key.base58EncodedString)
    }
    
    func testPubkeyRegex() throws {
        let regex = NSRegularExpression.publicKey
        XCTAssertTrue(regex.matches("3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"))
        XCTAssertTrue(regex.matches("5iqF9UNh6AB7hPkJiGFLixJuPeMqp9VVq7iJ9t8c3ZF"))
        XCTAssertTrue(regex.matches("CEUFMRm2cdr6UqCfPXAQnWqnndNVWuyk3QiC5gBN2k5"))
        XCTAssertTrue(regex.matches("JnfsZ5HahZnvnKsRZMsAf3D92e92C33NyufnrqAt2WL"))
        XCTAssertTrue(regex.matches("299wbEddCsswPqT9gv2gNAE6bxETMBKVuTrwdwtgvSMV"))
        XCTAssertTrue(regex.matches("2NrFPGGW8BKKU8hD48G3HhTXXRycd7fYbUKNEnmeLA97"))
        XCTAssertTrue(regex.matches("2kAQ6EL8Xhp1VXjM6JmwzVexFkWHYJoLnJNHRMWdkHKE"))
        XCTAssertTrue(regex.matches("36sp9nNMm4jja1h8wcvBYKyUYaqvHV1sfuBSJ5ddjcMd"))
        XCTAssertTrue(regex.matches("3Jc5CLBGd9dPfiXQ6K6ANu69g9mg9gHyKXxA2Gsk9qFa"))
        XCTAssertTrue(regex.matches("41r5NV6uj386xwXmeKwQ8V6mTH6Y4aouth5yQzeReFJt"))
        
        XCTAssertFalse(regex.matches("3h1zGmCwsRJnVk5BuR"))
        XCTAssertFalse(regex.matches("41r5NV6uj386xwXmeKwQ8V6mTH6Y4aouth5yQzeReFJt333"))
        XCTAssertFalse(regex.matches("41r5NV6uj386xwXm-KwQ8V6mTH6Y4+outh5yQzeReFJt"))
    }
    
    func testPublicKeyFromString() throws {
        let fromPublicKey = try Solana.PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
        XCTAssertEqual(fromPublicKey.bytes, [6, 26, 217, 208, 83, 135, 21, 72, 83, 126, 222, 62, 38, 24, 73, 163, 223, 183, 253, 2, 250, 188, 117, 178, 35, 200, 228, 106, 219, 133, 61, 12])
        
        let toPublicKey = try Solana.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
        XCTAssertEqual(toPublicKey.bytes, [235, 122, 188, 208, 216, 117, 235, 194, 109, 161, 177, 129, 163, 51, 155, 62, 242, 163, 22, 149, 187, 122, 189, 188, 103, 130, 115, 188, 173, 205, 229, 170])
        
        let programPubkey = try Solana.PublicKey(string: "11111111111111111111111111111111")
        XCTAssertEqual(programPubkey.bytes, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    }
    
    func testPublicKeyToString() throws {
        let key = try Solana.PublicKey(data: Data([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))
        XCTAssertEqual("CiDwVBFgWV9E5MvXWoLgnEgn2hK7rJikbvfWavzAQz3", key.base58EncodedString)
        
        let key1 = try Solana.PublicKey(string: "CiDwVBFgWV9E5MvXWoLgnEgn2hK7rJikbvfWavzAQz3")
        XCTAssertEqual("CiDwVBFgWV9E5MvXWoLgnEgn2hK7rJikbvfWavzAQz3", key1.base58EncodedString)
        
        let key2 = try Solana.PublicKey(string: "11111111111111111111111111111111")
        XCTAssertEqual("11111111111111111111111111111111", key2.base58EncodedString)
        
        let key3 = try Solana.PublicKey(data: Data([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]))
        XCTAssertEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], key3.bytes)
    }
    
    func testCreateAccountFromSecretKey() throws {
        let secretKey = Base58.decode("4Z7cXSyeFR8wNGMVXUE1TwtKn5D5Vu7FzEv69dokLv7KrQk7h6pu4LF8ZRR9yQBhc7uSM6RTTZtU1fmaxiNrxXrs")
        XCTAssertNotNil(secretKey)
        
        let account = try Solana.Account(secretKey: Data(secretKey))
        
        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", account.publicKey.base58EncodedString)
        XCTAssertEqual(64, account.secretKey.count)
    }
    
    #if canImport(UIKit)
    func testDerivedKeychain() throws {
        var keychain = try Keychain(seedString: "miracle pizza supply useful steak border same again youth silver access hundred", network: "mainnet-beta")
        
        keychain = try keychain.derivedKeychain(at: "m/501'/0'/0/0")
        
        let keys = try NaclSign.KeyPair.keyPair(fromSeed: keychain.privateKey!)
        
        XCTAssertEqual([UInt8](keys.secretKey), [109, 13, 53, 177, 69, 45, 146, 184, 62, 55, 105, 133, 210, 89, 131, 218, 248, 101, 47, 64, 81, 56, 229, 25, 173, 154, 12, 41, 66, 143, 230, 117, 39, 247, 185, 4, 85, 137, 50, 166, 147, 184, 221, 75, 110, 103, 16, 222, 41, 94, 247, 132, 43, 62, 172, 243, 95, 204, 190, 143, 153, 16, 10, 197])
    }
    #endif
    
    func testRestoreAccountFromSeedPhrase() throws {
        let phrase12 = "miracle pizza supply useful steak border same again youth silver access hundred"
            .components(separatedBy: " ")
        let account12 = try Solana.Account(phrase: phrase12, network: .mainnetBeta)
        XCTAssertEqual(account12.publicKey.base58EncodedString, "HnXJX1Bvps8piQwDYEYC6oea9GEkvQvahvRj3c97X9xr")
        
        let phrase24 = "budget resource fluid mutual ankle salt demise long burst sting doctor ozone risk magic wrap clap post pole jungle great update air interest abandon"
            .components(separatedBy: " ")
        let account24 = try Solana.Account(phrase: phrase24, network: .mainnetBeta)
        XCTAssertEqual(account24.publicKey.base58EncodedString, "9avcmC97zLPwHKXiDz6GpXyjvPn9VcN3ggqM5gsRnjvv")
    }
}
