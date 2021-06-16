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
}
